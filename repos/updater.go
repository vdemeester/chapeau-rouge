package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strings"

	"github.com/Masterminds/semver"
	"github.com/antchfx/htmlquery"
)

const (
	openshiftMirrorURL = "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/index.html"
)

var (
	versions  string
	archs     string
	platforms string
)

func main() {
	flag.StringVar(&versions, "version", "", "versions to list / extract")
	flag.StringVar(&archs, "arch", "", "architectures to list / extract")
	flag.StringVar(&platforms, "platform", "", "platform to list / extract")
	flag.Parse()

	args := flag.Args()
	if len(args) == 0 {
		fmt.Fprintln(os.Stderr, "one argument (filename) is required")
		os.Exit(1)
	}
	filename := args[0]

	versionsToFetch, err := getLatestVersions(strings.Split(versions, ","))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	m := map[string]interface{}{}
	for prefix, v := range versionsToFetch {
		shas, err := fetchVersion(filename, v, strings.Split(archs, ","), strings.Split(platforms, ","))
		if err != nil {
			fmt.Fprintln(os.Stderr, "error fetching version", err)
			os.Exit(1)
		}
		m[prefix] = shas
	}

	j, err := json.Marshal(m)
	if err != nil {
		fmt.Fprintln(os.Stderr, "error marshalling json", err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stdout, "%s", string(j))
}

func fetchVersion(filename, version string, archs, platforms []string) (map[string]interface{}, error) {
	m := map[string]interface{}{
		"version": version,
	}
	for _, platform := range platforms {
		realplatform := platform
		if platform == "darwin" {
			realplatform = "mac"
		}
		pm := map[string]string{}
		for _, arch := range archs {
			ocpArch := ""
			if arch == "aarch64" {
				ocpArch = "-arm64"
			}
			url := fmt.Sprintf("https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/%s/%s-%s%s-%s.tar.gz",
				version, filename, realplatform, ocpArch, version)
			args := []string{"--type", "sha256", url}
			fmt.Fprintf(os.Stderr, "Fetching %s...\n", url)
			out, err := exec.Command("nix-prefetch-url", args...).Output()
			if err != nil {
				fmt.Fprintln(os.Stderr, "nix-prefetch-url", args, string(out))
				return m, err
			}
			pm[arch] = strings.TrimSpace(string(out))
		}
		m[platform] = pm
	}
	return m, nil
}

func getLatestVersions(watchVersion []string) (map[string]string, error) {
	versionCollections := map[string]semver.Collection{}

	doc, err := htmlquery.LoadURL(openshiftMirrorURL)
	if err != nil {
		return nil, err
	}
	s := htmlquery.Find(doc, "//table//tr[@class=\"file\"]//td//a")
	if len(s) == 0 {
		return nil, nil
	}

	for _, d := range s {
		name := strings.TrimSuffix(htmlquery.SelectAttr(d, "href"), "/")
		v, err := semver.NewVersion(name)
		if err != nil {
			continue
		}
		groupBy := fmt.Sprintf("%d.%d", v.Major(), v.Minor())
		if _, ok := versionCollections[groupBy]; !ok {
			versionCollections[groupBy] = semver.Collection([]*semver.Version{})
		}
		versionCollections[groupBy] = append(versionCollections[groupBy], v)
	}

	r := map[string]string{}
	for _, wv := range watchVersion {
		versions := versionCollections[wv]
		sort.Sort(versions)
		r[wv] = versions[len(versions)-1].String()
	}
	return r, nil
}
