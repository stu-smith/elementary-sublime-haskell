#!/bin/bash

set -exu

if [ "$(id -u)" == "0" ]; then
	echo "This script must not be run using sudo."
	exit 1
fi

echo "Installing Sublime Text 3..."
mkdir -p ~/.config/sublime-text-3/Installed Packages
wget "http://packagecontrol.io/Package%20Control.sublime-package" -O ~/.config/sublime-text-3/Installed\ Packages/Package\ Control.sublime-package
rm -fr ~/.config/sublime-text-3/Packages/SublimeHaskell
git clone https://github.com/jcpetruzza/SublimeHaskell.git ~/.config/sublime-text-3/Packages/SublimeHaskell
cd ~/.config/sublime-text-3/Packages/SublimeHaskell && git checkout build-tools-with-sandbox
rm -fr ~/.config/sublime-text-3/Packages/User
mkdir ~/.config/sublime-text-3/Packages/User

cat <<"EOF" > ~/.config/sublime-text-3/Packages/User/SublimeHaskell.sublime-settings
{
	"add_to_PATH":
	[
		"/home/stu/.cabal/bin",
		"/opt/cabal/1.22/bin",
		"/opt/ghc/7.10.1/bin/"
	]
}
EOF

cd ~/.config/sublime-text-3/Packages/
git clone https://github.com/buymeasoda/soda-theme/ "Theme - Soda"
git clone https://github.com/jamiewilson/predawn "Predawn"
cd

cat <<"EOF" > ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
{
	"ignored_packages":
	[
		"Vintage"
	],
	"theme": "predawn.sublime-theme",
	"color_scheme": "Packages/Predawn/predawn.tmTheme",
	"tabs_small": true,
	"font_face": "Inconsolata",
	"font_size": 10,
	"highlight_line": true,
	"caret_extra_width": 1,
	"caret_style": "phase",
	"draw_minimap_border": true
}

EOF



echo "Configuring desktop..."
cat <<"EOF" > ~/.config/plank/dock1/launchers/sublime-text-3.dockitem
[PlankItemsDockItemPreferences]
Launcher=file:///usr/share/applications/sublime-text-3.desktop
EOF
cat <<"EOF" > ~/.config/plank/dock1/launchers/pgadmin3.dockitem
[PlankItemsDockItemPreferences]
Launcher=file:///usr/share/applications/pgadmin3.desktop
EOF
pkill plank && sed -i 's/DockItems=.*/DockItems=firefox.dockitem;;pantheon-terminal.dockitem;;pantheon-files.dockitem;;sublime-text-3.dockitem;;pgadmin3.dockitem;;switchboard.dockitem;;softwarecenter.dockitem;;update-manager.dockitem/g' ~/.config/plank/dock1/settings
gsettings set org.gnome.desktop.interface ubuntu-overlay-scrollbars false

cat <<"EOF" > ~/.profile
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

PATH="/opt/ghc/7.10.1/bin:/opt/cabal/1.22/bin:/opt/happy/1.19.4/bin:$PATH"

EOF

cat <<"EOF" > ~/.gconf/desktop/gnome/interface/%gconf.xml
<?xml version="1.0"?>
<gconf>
	<entry name="monospace_font_name" mtime="1415630398" type="string">
		<stringvalue>Inconsolata Medium 10</stringvalue>
	</entry>
</gconf>
EOF

PATH="/opt/ghc/7.10.1/bin:/opt/cabal/1.22/bin:/opt/happy/1.19.4/bin:$PATH"

mkdir -p ~/haskell-tools
cd ~/haskell-tools
cabal sandbox init
cabal update
cabal install hdevtools ghc-mod
