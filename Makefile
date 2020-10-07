.DEFAULT_GOAL := show-help
THIS_FILE := $(lastword $(MAKEFILE_LIST))
ROOT_DIR := $(shell dirname $(realpath $(THIS_FILE)))

.PHONY: show-help
# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.
## This help screen
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=29 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'

.PHONY: setup
## Installs dotfiles
setup:


.PHONY: brew-install
## Installs homebrew and dependencies in Brewfile
brew-install:
ifneq ($(shell which brew), /usr/local/bin/brew)
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
endif
	brew update
	brew tap Homebrew/bundle
	ln -f $(ROOT_DIR)/Brewfile $(HOME)/.Brewfile
	brew bundle --global
	brew cleanup

.PHONY: format-brewfile
## Orders the brew file
format-brewfile:
	cat $(ROOT_DIR)/Brewfile | sort | uniq | sed '/^[[:space:]]*$$/d' > $(ROOT_DIR)/brew/Brewfile.1
	mv $(ROOT_DIR)/Brewfile.1 Brewfile
	grep '^tap' $(ROOT_DIR)/Brewfile > Brewfile.1
	grep '^brew "mas"' $(ROOT_DIR)/Brewfile >> Brewfile.1
	grep '^cask' $(ROOT_DIR)/Brewfile >> $(ROOT_DIR)/Brewfile.1
	grep '^mas' $(ROOT_DIR)/Brewfile >> $(ROOT_DIR)/Brewfile.1
	grep '^brew' $(ROOT_DIR)/Brewfile >> $(ROOT_DIR)/Brewfile.1
	mv $(ROOT_DIR)/Brewfile.1 $(ROOT_DIR)/Brewfile
