VERSION = $(shell git describe --tags HEAD)
COMMIT_ID = $(shell git rev-parse --short HEAD || echo "HEAD")
BUILD_TIME = $(shell date -u '+%Y-%m-%dT%H:%M:%SZ')
CONNECTOR_FILENAME = connector.plugin.storage.qiniu.com
PLUGIN_FILENAME = plugin.storage.qiniu.com

.PHONY: all
all: build

.PHONY: build
build: connector/$(CONNECTOR_FILENAME) plugin/$(PLUGIN_FILENAME)

connector/$(CONNECTOR_FILENAME):
	cd connector && \
		go build -ldflags \
		"-X main.VERSION=$(VERSION) -X main.COMMITID=$(COMMIT_ID) -X main.BUILDTIME=$(BUILD_TIME)" \
		-o $(CONNECTOR_FILENAME)

plugin/$(PLUGIN_FILENAME):
	cd plugin && \
		go build -ldflags \
		"-X main.VERSION=$(VERSION) -X main.COMMITID=$(COMMIT_ID) -X main.BUILDTIME=$(BUILD_TIME)" \
		-o $(PLUGIN_FILENAME)

.PHONY: clean
clean:
	rm -f connector/$(CONNECTOR_FILENAME) \
		plugin/$(PLUGIN_FILENAME)

.PHONY: build_image
build_image:
	docker build --pull \
		-t="kodoproduct/csi-$(PLUGIN_FILENAME):${VERSION}" \
		-f Dockerfile .

.PHONY: push_image
push_image: build_image
	docker push "kodoproduct/csi-$(PLUGIN_FILENAME):${VERSION}"
