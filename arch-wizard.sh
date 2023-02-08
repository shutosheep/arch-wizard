#!/bin/sh

srcdir="$HOME/.local/src"

dwmrepo="https://github.com/shutosheep/dwm.git"
strepo="https://github.com/LukeSmithxyz/st.git"
dmenurepo="https://github.com/LukeSmithxyz/dmenu.git"
dwmblocksrepo="https://github.com/shutosheep/dwmblocks.git"
dotfilesrepo="https://github.com/shutosheep/dotfiles.git"

x11setup() {
    echo "Setting up dwm..."

    echo "Installing dependencies..."

    sudo pacman -Sy --noconfirm $(grep "dwm" packages.csv | cut -d "," -f 1)

    # create srcdir if it doesn't exist
    [ -d "$srcdir" ] || mkdir -p "$srcdir"

    git clone "$dwmrepo" "$srcdir/dwm"
    git clone "$strepo" "$srcdir/st"
    git clone "$dmenurepo" "$srcdir/dmenu"
    git clone "$dwmblocksrepo" "$srcdir/dwmblocks"

    sudo make install -C "$srcdir/dwm"
    sudo make install -C "$srcdir/st"
    sudo make install -C "$srcdir/dmenu"
    sudo make install -C "$srcdir/dwmblocks"
}

dotfilessetup() {
    echo "Setting up dotfiles..."

    echo "Installing dependencies..."

    sudo pacman -Sy --noconfirm $(grep "dotfiles" packages.csv | cut -d "," -f 1)

    # create srcdir if it doesn't exist
    [ -d "$srcdir" ] || mkdir -p "$srcdir"

    git clone "$dotfilesrepo" "$srcdir/dotfiles"

    # create non-existing directory (to support linking files later)
    for d in $(find $srcdir/dotfiles \
        -path "$srcdir/dotfiles/.git" -prune -o \
        -path "$srcdir/dotfiles/.github" -prune -o \
        -type d -print); do
        dd="$(echo $d | sed "s,$srcdir/dotfiles,$HOME,g")"
        # create dd if it doesn't exist
        [ -d "$dd" ] || mkdir -p "$dd"
    done

    # linking files
    for f in $(find $srcdir/dotfiles \
        -path "$srcdir/dotfiles/.git" -prune -o \
        -path "$srcdir/dotfiles/.github" -prune -o \
        -type f -print); do
        ff="$(echo "$f" | sed "s,$srcdir/dotfiles,$HOME,g")"
        ln -sf "$f" "$ff"
    done
}

gitsetup() {
    echo "Setting up git..."

    echo "Please input your name and email for commit message"
    read -p "> Your name? " name
    read -p "> Your email? " email
    read -p "> Do you want to use 'main' as initial branch name? [y/N] " branch

    git config --global user.name "$name"
    git config --global user.email "$email"

    case "$branch" in
        [yY]) git config --global init.defaultBranch main ;;
    esac
}

showhelp() {
    cat << EOF
arch-wizard:    Setup programs easily on fresh Arch Linux install

commands:
    x11         Setup x11 desktop environment (dwm)
    dotfiles    Deploy dotfiles
    git         Set git username and email
    help        Show this help message
EOF
}

case "$1" in
    x11) x11setup || exit 1 ;;
    dotfiles) dotfilessetup || exit 1 ;;
    git) gitsetup || exit 1 ;;
    help) showhelp ;;
    *) showhelp; exit 1 ;;
esac
