#!/bin/sh
set -e

### HELPER METHODS ###

install_via_github_app () {
  if ! [ -a /Applications/GitHub.app ]; then
    echo "Downloading GitHub app..."
    curl -o ~/Downloads/GitHubForMac.zip -L https://central.github.com/mac/latest
    unzip ~/Downloads/GitHubForMac.zip -d /Applications/
    echo "...done."
  fi

  echo "Opening GitHub app. Once open,\n1. Open 'GitHub' menu in the top left\n2. Click 'Preferences...'\n3. Click 'Advanced' tab\n4. Click 'Install Command Line Tools'"
  read -p "Press ENTER to continue. > "
  open /Applications/GitHub.app
  read -p "Press ENTER when done. > "
}

install_git () {
  # TODO handle OSes other than OSX
  if which xcode-select; then
    echo "Installing command-line tools..."
    xcode-select --install
  else
    install_via_github_app
  fi

  # re-check for Git
  if which git; then
    echo "$(git --version) successfully installed."
  else
    echo "Git failed to install. Please try again, or open an issue at https://github.com/afeld/git-setup/issues."
    exit 1
  fi
}

# usage:
#   is_set PROPERTY
config_is_set () {
  OUTPUT=$(git config --global --get $1)
  if [ -n "$OUTPUT" ]; then
    echo "EXISTS: $1=$OUTPUT"
    return 0
  else
    return 1
  fi
}

set_config () {
  echo "NEW:    $1=$2"
  git config --global --add $1 $2
}

# usage:
#   config_unless_set PROPERTY VALUE
config_unless_set () {
  if ! config_is_set $1; then
    set_config $1 $2
  fi
}

# usage:
#   prompt_unless_set PROPERTY PROMPT
prompt_unless_set () {
  if ! config_is_set $1; then
    read -p "$2 > " VAL
    set_config $1 $VAL
  fi
}

######################

# check if Git is installed
# TODO check that version is >= 1.7.10 (for autocrlf)
if which git; then
  echo "$(git --version) already installed."
else
  install_git
fi

# user-specified settings
prompt_unless_set user.name "What's your full name?"
prompt_unless_set user.email "What's your email?"

# recommended defaults
config_unless_set branch.autosetupmerge true
config_unless_set color.ui true
config_unless_set core.autocrlf input
config_unless_set push.default upstream


# TODO set up global .gitignore


# TODO add credential helper


echo "Complete!"
