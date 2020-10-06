# Mirah's Dotfiles

This exists primarily for the purposes of backing up my config, especially after I lost all my zsh config once in the middle of customizing it.

## Setup

There's a lot to do here, eventually there will be a makefile or a setup script or something along those lines, like

```
git clone git@github.com:MirahImage/dotfiles.git && \
    pushd dotfiles && \
    make setup-home
```

For now, just clone the repo, then `ln` the files to the home directory with a `.` in front. Except the zsh theme, which goes in `.oh-my-zsh/custom/themes/`
