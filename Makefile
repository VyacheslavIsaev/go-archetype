GOLANGCI_LINT_VERSION := v1.21.0
TMP_PROJECT_NAME=my-go-project
TMP_DIR=.tmp/go/$(TMP_PROJECT_NAME)
BIN_DIR := $(GOPATH)/bin
GOLANGCI_LINT := $(BIN_DIR)/golangci-lint

all: test lint

tidy:
	go mod tidy -v

build:
	go build ./...

test: build
	go test -cover -race ./...

test-coverage:
	go test ./... -race -coverprofile=coverage.txt && go tool cover -html=coverage.txt

ci-test: build
	go test -race $$(go list ./...) -v -coverprofile coverage.txt -covermode=atomic

cleanup-test-dir:
	rm -rf $(TMP_DIR)
	mkdir -p $(TMP_DIR)

test-template: cleanup-test-dir
	LOG_LEVEL=debug go run main.go transform --transformations=transformations.yml \
		--source=. \
		--destination=$(TMP_DIR) \
		-- \
		--ProjectName my-go-project \
		--IncludeReadme no \
		--ProjectDescription "bla bla"

	cd $(TMP_DIR) &&\
		make

test-goreleaser-config:
	goreleaser --snapshot --skip-publish --rm-dist

release: guard-TAG
	@echo
	@echo
	@echo Adding new tag: $(TAG)
	@echo
	git tag -a v$(TAG)
	git push --tags

setup: setup-git-hooks

setup-git-hooks:
	git config core.hooksPath .githooks

lint: $(GOLANGCI_LINT)
	$(GOPATH)/bin/golangci-lint run --fast --enable-all -D gochecknoglobals -D gochecknoinits -D prealloc -D wsl

$(GOLANGCI_LINT):
	GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
