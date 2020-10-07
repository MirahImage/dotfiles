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
setup: brew-install setup-zsh configure-git configure-tmux smith go-tools vscode-extensions


.PHONY: setup-zsh
## Installs oh-my-zsh and configures zsh dotfiles
setup-zsh:
	# Install oh-my-zsh if not present
	if [ ! -d "$(HOME)/.oh-my-zsh" ]; then \
		curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh && \
		rm $(HOME)/.zshrc; \
	fi
	# Update zsh dotfiles
	ln -f $(ROOT_DIR)/zshrc $(HOME)/.zshrc
	ln -f $(ROOT_DIR)/zshenv $(HOME)/.zshenv
	# Add custom theme
	ln -f $(ROOT_DIR)/custom-refined.zsh-theme $(HOME)/.oh-my-zsh/custom/themes/custom-refined.zsh-theme

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

.PHONY: configure-git
## Configures git dotfiles
configure-git:
	ln -f $(ROOT_DIR)/gitconfig $(HOME)/.gitconfig
	ln -f $(ROOT_DIR)/gitignore_global $(HOME)/.gitignore_global

.PHONY: configure-tmux
## Configures tmux
configure-tmux:
	ln -f $(ROOT_DIR)/tmux.conf $(HOME)/.tmux.conf
	if [ ! -d $(HOME)/.tmux/plugins/tpm ]; then \
		mkdir -p $(HOME)/.tmux/plugins && \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm && \
		$(HOME)/.tmux/plugins/tpm/bin/install_plugins all; else \
		cd $(HOME)/.tmux/plugins/tpm && \
		git pull && \
		$(HOME)/.tmux/plugins/tpm/bin/update_plugins all; fi

.PHONY: smith
## Add smith and token hook
smith:
	go get -u github.com/pivotal/smith
	ln -f $(ROOT_DIR)/smith-token-hook.sh $(HOME)/.smith-token-hook.sh

.PHONY: go-tools
## Install golang tools
go-tools:
	go get -u github.com/onsi/ginkgo/ginkgo \
		github.com/onsi/gomega

.PHONY: vscode-extensions
## Install vscode extensions
vscode-extensions:
	code --install-extension minherz.copyright-inserter
	code --install-extension ms-azuretools.vscode-docker
	code --install-extension pgourlain.erlang
	code --install-extension golang.go
	code --install-extension hashicorp.terraform
	code --install-extension johnpapa.vscode-peacock
	code --install-extension rebornix.ruby
	code --install-extension castwide.solargraph
	code --install-extension timonwong.shellcheck
	code --install-extension sonarsource.sonarlint-vscode
	code --install-extension redhat.vscode-xml
	code --install-extension gamunu.vscode-yarn
