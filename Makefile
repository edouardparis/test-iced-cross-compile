# Variables
PROJECT_NAME := test-iced-cross-compile
VERSION := 0.1.0
BUILD_DIR := target
OUTPUT_DIR := deb_package
ARCH := amd64

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make build           - Build the project for GNU (default target)"
	@echo "  make build/musl      - Build the project with MUSL"
	@echo "  make package         - Package the GNU binary into a .deb"
	@echo "  make package/musl    - Package the MUSL binary into a .deb"

# Build GNU target
.PHONY: build
build:
	cargo build --release --target x86_64-unknown-linux-gnu

# Build MUSL target
.PHONY: build/musl
build/musl:
	cargo build --release --target x86_64-unknown-linux-musl

# Package GNU binary
.PHONY: package
package: build
	$(eval BINARY := $(BUILD_DIR)/x86_64-unknown-linux-gnu/release/$(PROJECT_NAME))
	@$(MAKE) package-common TARGET=x86_64-unknown-linux-gnu BINARY=$(BINARY)

# Package MUSL binary
.PHONY: package/musl
package/musl: build/musl
	$(eval BINARY := $(BUILD_DIR)/x86_64-unknown-linux-musl/release/$(PROJECT_NAME))
	@$(MAKE) package-common TARGET=x86_64-unknown-linux-musl BINARY=$(BINARY)

# Common packaging logic
.PHONY: package-common
package-common:
	@if [ ! -f "$(BINARY)" ]; then echo "Error: Binary not found! Build it first."; exit 1; fi
	# Prepare packaging directory
	rm -rf $(OUTPUT_DIR)
	mkdir -p $(OUTPUT_DIR)/DEBIAN
	mkdir -p $(OUTPUT_DIR)/usr/local/bin
	# Copy binary
	cp $(BINARY) $(OUTPUT_DIR)/usr/local/bin/
	# Create control file
	echo "Package: $(PROJECT_NAME)" > $(OUTPUT_DIR)/DEBIAN/control
	echo "Version: $(VERSION)" >> $(OUTPUT_DIR)/DEBIAN/control
	echo "Section: base" >> $(OUTPUT_DIR)/DEBIAN/control
	echo "Priority: optional" >> $(OUTPUT_DIR)/DEBIAN/control
	echo "Architecture: $(ARCH)" >> $(OUTPUT_DIR)/DEBIAN/control
	echo "Maintainer: Your Name <you@example.com>" >> $(OUTPUT_DIR)/DEBIAN/control
	echo "Description: $(PROJECT_NAME) binary for $(TARGET)" >> $(OUTPUT_DIR)/DEBIAN/control
	# Build the .deb package
	dpkg-deb --build $(OUTPUT_DIR)
	mv $(OUTPUT_DIR).deb $(PROJECT_NAME)_$(VERSION)_$(TARGET).deb

# Clean target
.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)
	rm -f *.deb

