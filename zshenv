export PATH=/usr/local/sbin:$PATH

# Setup Go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

export PATH=$PATH:$HOME/workspace/rabbitmq-tile-home/bin
export PATH=$PATH:$HOME/workspace/rabbitmq-for-k8s-home/bin

export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:$HOME/.krew/bin

# Mac uses an ancient version of ruby, use homebrew ruby instead
export PATH="/opt/homebrew/opt/ruby@3.1/bin:$PATH"

export PATH=$PATH:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin

. "$HOME/.cargo/env"
