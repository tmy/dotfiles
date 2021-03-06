#!/bin/zsh

cd "$HOME"

libs=(
    "Library/Application Support/CotEditor"
    "Library/Application Support/IntelliJIdea"*
    "Library/Application Support/OmniGraffle"
    "Library/Application Support/SIMBL/Plugins"
    "Library/Application Support/TextExtras"
    "Library/Application Support/TextMate"
    "Library/ColorPickers"
    "Library/Colors"
    "Library/KeyBindings"
    "Library/PreferencePanes"
    "Library/Preferences/IntelliJIdea"*
    "Library/QuickLook"
    "Library/Services"
    "Library/SoftwareLicenses"
    "Library/Widgets"
)

base_dir=~
dropbox_dir=~/Dropbox
backup_dir=~/move_to_dropbox

echo $dropbox
for lib in $libs ; do
    target="$base_dir/$lib"
    move_to="$backup_dir/$lib"
    link_to="$dropbox_dir/$lib"
    if [ -e "$target" -a ! -L "$target" ] ; then
        if [ ! -e "$link_to" ] ; then
            echo Move \"$lib\" to Dropbox...
            mv "$target" "$link_to"
        else
            echo Backup \"$target\"...
            dirname=`dirname "$move_to"`
            if [ ! -d "$dirname" ] ; then
                mkdir -p "$dirname"
            fi
            mv "$target" "$move_to"
        fi
    fi
    if [ ! -L "$target" ] ; then
        echo Create Symlink in \"$target\" to \"$link_to\"...
        ln -s "$link_to" "$target"
    fi
done
