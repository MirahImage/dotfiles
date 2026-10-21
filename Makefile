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
setup: brew zsh git tmux go-tools vscode repos allow-internet kiex


.PHONY: zsh
## Installs oh-my-zsh and configures zsh dotfiles
zsh:
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
	# Add zsh-syntax-highlighting plugin
	if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		git clone git@github.com:zsh-users/zsh-syntax-highlighting.git $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; fi
	cd $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull

.PHONY: brew
## Installs homebrew and dependencies in Brewfile
brew:
ifneq ($(shell which brew), /usr/local/bin/brew)
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
endif
	brew update
	ln -f $(ROOT_DIR)/Brewfile $(HOME)/.Brewfile
	brew bundle --global
	brew cleanup

.PHONY: keys
## Loads SSH and GPG keys for interacting with GitHub. Interactive
keys:
	echo "pinentry-program $(shell which pinentry-mac)" > $(HOME)/.gnupg/gpg-agent.conf
	killall gpg-agent
	gpg --import <(lpass show "Personal/Broadcom-GPG-key" --notes)
	mkdir -p $(HOME)/.ssh
	lpass show "Personal/key" --notes > $(HOME)/.ssh/ssh-key && chmod 0600 $(HOME)/.ssh/ssh-key
	eval "$(ssh-agent -s )" && ssh-add -D && ssh-add $(HOME)/.ssh/ssh-key

.PHONY: git
## Configures git dotfiles
git:
	ln -f $(ROOT_DIR)/gitconfig $(HOME)/.gitconfig
	ln -f $(ROOT_DIR)/gitignore_global $(HOME)/.gitignore_global
	ln -f $(ROOT_DIR)/tigrc $(HOME)/.tigrc
	mkdir -p $(HOME)/.config/git-mit && lpass show "git-mit.toml" --notes > $(HOME)/.config/git-mit/mit.toml
	if [ ! -d $(HOME)/workspace ]; then mkdir -p $(HOME)/workspace; fi

.PHONY: tmux
## Configures tmux
tmux:
	ln -f $(ROOT_DIR)/tmux.conf $(HOME)/.tmux.conf
	if [ ! -d $(HOME)/.tmux/plugins/tpm ]; then \
		mkdir -p $(HOME)/.tmux/plugins && \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm && \
		$(HOME)/.tmux/plugins/tpm/bin/install_plugins all; else \
		cd $(HOME)/.tmux/plugins/tpm && \
		git pull && \
		$(HOME)/.tmux/plugins/tpm/bin/update_plugins all; fi

.PHONY: go-tools
## Install golang tools
go-tools:
	go install github.com/onsi/ginkgo/v2/ginkgo@latest \
		github.com/onsi/gomega@latest \
		github.com/elastic/crd-ref-docs@latest
	$(eval KUBEBUILDER_VERSION := $(shell curl --silent "https://api.github.com/repos/kubernetes-sigs/kubebuilder/releases/latest" | jq -r .tag_name | sed 's/v//'))
	$(eval OS := $(shell go env GOOS))
	$(eval ARCH := $(shell go env GOARCH))
	curl -L "https://github.com/kubernetes-sigs/kubebuilder/releases/download/v$(KUBEBUILDER_VERSION)/kubebuilder_$(KUBEBUILDER_VERSION)_$(OS)_$(ARCH).tar.gz" | tar -xz -C /tmp/ && \
		sudo mv "/tmp/kubebuilder_$(KUBEBUILDER_VERSION)_$(OS)_$(ARCH)" /usr/local/kubebuilder

.PHONY: vscode
## Install vscode extensions
vscode:
	ln -f $(ROOT_DIR)/vscode_settings.json $(HOME)/Library/Application\ Support/VSCodium/User/settings.json
	codium --install-extension dracula-theme.theme-dracula
	codium --install-extension erlang-ls.erlang-ls
	codium --install-extension golang.go
	codium --install-extension johnpapa.vscode-peacock
	codium --install-extension opentofu.vscode-opentofu
	codium --install-extension rebornix.ruby
	codium --install-extension timonwong.shellcheck
	codium --install-extension redhat.vscode-xml
	codium --install-extension gamunu.vscode-yarn
	codium --install-extension tamasfe.even-better-toml
	codium --install-extension jebbs.plantuml

.PHONY: repos
## Clone git repos
repos:
	ln -f $(ROOT_DIR)/mrconfig $(HOME)/.mrconfig
	cd $(HOME) && \
		mr update -q -j 4 --rebase --autostash

.PHONY: allow-internet
## Allow executables from the internet
allow-internet:
	sudo spctl --master-disable

.PHONY: ruby
## Install ruby and dependencies
ruby: brew
	ruby-install ruby-2.7.2
	gem update --system
	gem install bundler
	bundle config --global jobs $(($(sysctl -n hw.ncpu) -1))

.PHONY: kiex
## Install kiex for elixir
kiex:
	curl -sSL https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s
