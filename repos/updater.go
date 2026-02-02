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
	versions   string
	minVersion string
	archs      string
	platforms  string
	autoDetect bool
)

func main() {
	flag.StringVar(&versions, "version", "", "versions to list / extract (comma-separated, e.g., '4.14,4.15')")
	flag.StringVar(&minVersion, "min-version", "", "minimum version to track (e.g., '4.14'), auto-detects all versions >= this")
	flag.StringVar(&archs, "arch", "", "architectures to list / extract")
	flag.StringVar(&platforms, "platform", "", "platform to list / extract")
	flag.BoolVar(&autoDetect, "auto", false, "auto-detect all available versions (use with -min-version to filter)")
	flag.Parse()

	args := flag.Args()
	if len(args) == 0 {
		fmt.Fprintln(os.Stderr, "one argument (filename) is required")
		os.Exit(1)
	}
	filename := args[0]

	var versionsToFetch map[string]string
	var err error

	if autoDetect || minVersion != "" {
		// Auto-detect versions from mirror
		versionsToFetch, err = autoDetectVersions(minVersion)
	} else if versions != "" {
		// Use explicitly specified versions
		versionsToFetch, err = getLatestVersions(strings.Split(versions, ","))
	} else {
		fmt.Fprintln(os.Stderr, "either -version, -min-version, or -auto must be specified")
		os.Exit(1)
	}

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

// getAllVersionCollections parses the mirror and returns all version collections grouped by major.minor
func getAllVersionCollections() (map[string]semver.Collection, error) {
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

	return versionCollections, nil
}

// autoDetectVersions finds all available major.minor versions and returns the latest patch for each
// If minVer is specified, only versions >= minVer are included
func autoDetectVersions(minVer string) (map[string]string, error) {
	versionCollections, err := getAllVersionCollections()
	if err != nil {
		return nil, err
	}

	var minSemver *semver.Version
	if minVer != "" {
		minSemver, err = semver.NewVersion(minVer)
		if err != nil {
			return nil, fmt.Errorf("invalid min-version %q: %w", minVer, err)
		}
	}

	r := map[string]string{}
	for groupBy, versions := range versionCollections {
		sort.Sort(versions)
		latestInGroup := versions[len(versions)-1]

		// Skip if below minimum version
		if minSemver != nil {
			// Compare major.minor only
			groupVersion, err := semver.NewVersion(groupBy + ".0")
			if err != nil {
				continue
			}
			minGroupVersion, _ := semver.NewVersion(fmt.Sprintf("%d.%d.0", minSemver.Major(), minSemver.Minor()))
			if groupVersion.LessThan(minGroupVersion) {
				continue
			}
		}

		r[groupBy] = latestInGroup.String()
		fmt.Fprintf(os.Stderr, "Detected version %s -> %s\n", groupBy, latestInGroup.String())
	}

	return r, nil
}

// getLatestVersions returns the latest patch version for each specified major.minor version
func getLatestVersions(watchVersion []string) (map[string]string, error) {
	versionCollections, err := getAllVersionCollections()
	if err != nil {
		return nil, err
	}

	r := map[string]string{}
	for _, wv := range watchVersion {
		versions := versionCollections[wv]
		if len(versions) == 0 {
			fmt.Fprintf(os.Stderr, "Warning: no versions found for %s\n", wv)
			continue
		}
		sort.Sort(versions)
		r[wv] = versions[len(versions)-1].String()
	}
	return r, nil
}
