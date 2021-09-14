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
export PATH=/usr/local/opt/ruby/bin:$PATH

export PATH=$PATH:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin

export PATH=/usr/local/opt/ruby/bin:$PATH
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby ruby-2.7.2
. "$HOME/.cargo/env"

# use lima+nerdctl instead of docker
alias docker="lima nerdctl"
