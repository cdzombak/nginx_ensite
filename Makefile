SHELL=/usr/bin/env bash

NAME=nginx_ensite
AUTHOR=cdzombak
URL=https://github.com/$(AUTHOR)/$(NAME)
VERSION=$(shell ./.version.sh)
PKG_NAME=$(NAME)-$(VERSION)

DIRS=bin share
INSTALL_DIRS=`find $(DIRS) -type d`
INSTALL_FILES=`find $(DIRS) -type f`
DOC_FILES=*.ronn
PREFIX?=/usr/local
DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)
COMPLETION_DIR=/etc/bash_completion.d

default: help
.PHONY: help  # via https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print help
	@grep -E '^[a-zA-Z_-\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

share/man/man8/nginx_ensite.8: doc/man/nginx_ensite.8.ronn
	ronn --roff doc/man/nginx_ensite.8.ronn
	cp doc/man/nginx_ensite.8 share/man/man8/nginx_ensite.8

share/man/man8/nginx_ensite.8.gz: share/man/man8/nginx_ensite.8
	gzip -kf share/man/man8/nginx_ensite.8

share/man/man8/nginx_dissite.8.gz: share/man/man8/nginx_dissite.8
	gzip -kf share/man/man8/nginx_dissite.8

.PHONY: build/man
build/man: share/man/man8/nginx_ensite.8.gz share/man/man8/nginx_dissite.8.gz ## Build manpages to share/man

.PHONY: lint
lint: ## Run shellcheck on shell scripts
	shellcheck -S error bin/nginx_ensite

.PHONY: clean
clean: ## Remove temporary build products
	rm -rf out/

.PHONY: build/package
build/package: build/man ## Build package to ./out
	mkdir -p out
	fpm -t deb -v ${VERSION} -p ./out/${NAME}-${VERSION}-all.deb \
		./bin/=/usr/bin/ \
		./share/man/man8/nginx_ensite.8.gz=/usr/share/man/man8/nginx_ensite.8.gz \
		./share/man/man8/nginx_dissite.8.gz=/usr/share/man/man8/nginx_dissite.8.gz \
		./bash_completion.d/=/usr/share/bash-completion/completions/

.PHONY: install
install: ## Install (default to /usr/local)
	for dir in $(INSTALL_DIRS); do mkdir -p $(DESTDIR)$(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(DESTDIR)$(PREFIX)/$$file; done
	(cd $(DESTDIR)$(PREFIX)/bin && test -L nginx_dissite || ln -s nginx_ensite nginx_dissite)
	mkdir -p $(DESTDIR)$(DOC_DIR)
	cp -r doc/man/$(DOC_FILES) $(DESTDIR)$(DOC_DIR)/
	mkdir -p $(COMPLETION_DIR)
	cp bash_completion.d/* $(COMPLETION_DIR)/

.PHONY: uninstall
uninstall: ## Uninstall (default from /usr/local)
	for file in $(INSTALL_FILES); do rm -f $(DESTDIR)$(PREFIX)/$$file; done
	rm -rf $(DESTDIR)$(DOC_DIR)
	rm $(COMPLETION_DIR)/$(NAME)
