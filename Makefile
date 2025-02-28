default: help

help:
	@echo "  Usage:\n    \033[36m make <target>\n\n \033[0m Targets:"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep  | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "     \033[36m%-30s\033[0m %s\n", $$1, $$2}'

template: ## Install and update MVVM-C Scene template to Xcode
	@sh -c "cd ArchitectureTemplate; swiftc install.swift -o ./install; sudo ./install"
	@rm ArchitectureTemplate/install


setuptools: ## Install project required tools
	@./Scripts/SetupTools/setup.sh

certificates: ## Install/Update certificates
	@bundle exec fastlane match_certificates

generate: ## Generate projects, wåorkspace and install pods
	@./Scripts/killXcode.sh
	@$(MAKE) generatesources
	@$(MAKE) generateprojects
	@$(MAKE) generateworkspace
	@./Scripts/Generate/postGenerate.sh $(open)
	
generateprojects: ## Generate only .xcodeproj projects using Xcodegen
	@. ./Scripts/asyncGenerateProjects.sh;
	
generateworkspace: ## Generate only .xcodeproj projects using Xcodegen
	@. ./Scripts/generateWorkspace.sh;

generatesources: ## Generate source files with Swiftgen and Sourcery
	@./Scripts/generateResources.sh

clean: ## Cleanup projects
	-@rm -Rf ./VidaaS.xcodeproj

cleanall: ## Cleanup projects
	@$(MAKE) clean
	@git clean -fdx

install_bundler: ## Run bundler after installing correct version
	@./Scripts/Bundler/installBundler.sh
