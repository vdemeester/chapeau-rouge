package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strings"
)

const (
	readmePath         = "README.md"
	packagesStartToken = "<!-- PACKAGES_START -->"
	packagesEndToken   = "<!-- PACKAGES_END -->"
)

type FlakeShowOutput struct {
	Packages map[string]map[string]PackageInfo `json:"packages"`
}

type PackageInfo struct {
	Name string `json:"name"`
}

type Package struct {
	Name      string
	Version   string
	Platforms []string
}

func main() {
	// Get the flake show output
	flakeOutput, err := getFlakeShowOutput()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error getting flake show output: %v\n", err)
		os.Exit(1)
	}

	// Parse the packages
	packages := parsePackages(flakeOutput)

	// Generate the markdown for the package list
	packagesMarkdown := generatePackagesMarkdown(packages)

	// Read the README.md file
	readmeBytes, err := os.ReadFile(readmePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading README.md: %v\n", err)
		os.Exit(1)
	}
	readmeContent := string(readmeBytes)

	// Update the README.md content
	newReadmeContent := updateReadme(readmeContent, packagesMarkdown)

	// Write the new content back to README.md
	err = os.WriteFile(readmePath, []byte(newReadmeContent), 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing README.md: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("README.md updated successfully.")
}

func getFlakeShowOutput() (*FlakeShowOutput, error) {
	cmd := exec.Command("nix", "flake", "show", "--json", "--all-systems")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var flakeOutput FlakeShowOutput
	err = json.Unmarshal(output, &flakeOutput)
	if err != nil {
		return nil, err
	}

	return &flakeOutput, nil
}

func parsePackages(flakeOutput *FlakeShowOutput) []Package {
	packageMap := make(map[string]Package)

	for platform, platformPackages := range flakeOutput.Packages {
		for pkgName, pkgInfo := range platformPackages {
			if pkgInfo.Name == "" {
				continue
			}

			parts := strings.Split(pkgInfo.Name, "-")
			version := parts[len(parts)-1]

			if existingPkg, ok := packageMap[pkgName]; ok {
				existingPkg.Platforms = append(existingPkg.Platforms, platform)
				sort.Strings(existingPkg.Platforms)
				packageMap[pkgName] = existingPkg
			} else {
				packageMap[pkgName] = Package{
					Name:      pkgName,
					Version:   version,
					Platforms: []string{platform},
				}
			}
		}
	}

	var packages []Package
	for _, pkg := range packageMap {
		packages = append(packages, pkg)
	}

	sort.Slice(packages, func(i, j int) bool {
		return packages[i].Name < packages[j].Name
	})

	return packages
}

func generatePackagesMarkdown(packages []Package) string {
	var builder strings.Builder
	builder.WriteString(packagesStartToken + "\n")
	builder.WriteString("## Packages\n\n")
	builder.WriteString("| Package | Version | Platforms |\n")
	builder.WriteString("|---|---|---|\n")
	for _, pkg := range packages {
		platforms := make([]string, len(pkg.Platforms))
		for i, p := range pkg.Platforms {
			platforms[i] = fmt.Sprintf("`%s`", p)
		}
		builder.WriteString(fmt.Sprintf("| `%s` | `%s` | %s |\n", pkg.Name, pkg.Version, strings.Join(platforms, ", ")))
	}
	builder.WriteString("\n" + packagesEndToken)
	return builder.String()
}

func updateReadme(readmeContent, packagesMarkdown string) string {
	start := strings.Index(readmeContent, packagesStartToken)
	end := strings.Index(readmeContent, packagesEndToken)

	if start != -1 && end != -1 {
		return readmeContent[:start] + packagesMarkdown + readmeContent[end+len(packagesEndToken):]
	}

	// If the tokens are not present, add the packages section before "Quickstart"
	quickstartSection := "## Quickstart"
	quickstartPos := strings.Index(readmeContent, quickstartSection)
	if quickstartPos != -1 {
		return readmeContent[:quickstartPos] + packagesMarkdown + "\n\n" + readmeContent[quickstartPos:]
	}

	// If "Quickstart" is not found, append at the end
	return readmeContent + "\n" + packagesMarkdown
}
