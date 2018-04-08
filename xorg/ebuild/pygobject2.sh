build() {
    VERSION="2.28.7"
    EXT="xz"
    URL="http://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-$VERSION.tar.$EXT"
    pull $PKG $EXT $VERSION $URL
    unpack pygobject-$VERSION $EXT pygobject2-$VERSION.tar.$EXT
    make install && cleanup
}