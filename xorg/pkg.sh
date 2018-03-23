export SOURCES="/dev/shm"
export SRCS="/tmp"
export EBUILDS="./ebuild"
export ROOT=$(pwd)
export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

unpack() {
	PKG=$1
	FILE=$PKG.tar.$2
	TARGET=$FILE
	cd $SRCS
	if [ -n "$3" ]; then
		TARGET=$SOURCES/$3
	else
		TARGET=$SOURCES/$FILE
	fi

	if [ ! -f $TARGET ]; then
		echo "unpack error: unable to find $TARGET"
		exit 1
	fi

	if [ -d $PKG ]; then
		echo "unpack cleaning previous installation"
		rm -r $PKG
	fi
	echo "Extracting $PKG"
	tar -xf $TARGET
	if [ ! -d $PKG ]; then
		echo "failed to unpack source, check if $FILE exists"
		exit 1
	fi
	cd $PKG
	echo "unpack of $PKG ok"
}

# usage: compile [PKG] <threads to use>
compile() {
	PKG=$1
	echo "Compiling $PKG"
	make -j$2
	if [ $? != 0 ]; then
		echo "compilation failed for $PKG"
		exit 1
	fi
}

# usage : build_generic PKG SOURCEFILE <options to configure>
build_generic() {
	PKG=$1
	echo "Building $PKG"
	unpack $PKG $2
	if [ -f configure ]; then
		echo "Configuring $PKG from $(pwd)"
		./configure --prefix=/tools $3
		if [ $? != 0 ]; then
			echo "Error: failed to configure $PKG"
			exit 1
		fi
	fi
	compile $PKG
	echo "Installing"
	make $4 install
	echo "$PKG done."
}


# usge: pull [PKG] [EXT] [VERSION] [URL]
pull() {
	PKG=$1
	EXT=$2
	VERSION=$3
	FILE=$PKG-$VERSION.tar.$EXT
	if [ -f $SOURCES/$FILE ]; then
		echo "$PKG source already here."
		return
	fi
	URL=$4
	echo "getting $PKG from $URL"
	wget $URL -O $SOURCES/$FILE --no-check-certificate
	if [ $? != 0 ]; then
		echo "error: failed to get $PKG at $URL"
		exit 1
	fi
	echo "Successfully retrived $PKG-$VERSION"
}

build_pkg() {
	PKG=$1
	FILE=$EBUILDS/$PKG.sh
	cd $ROOT
	if [ ! -f $FILE ]; then
		echo "no such package $PKG"
		return 1
	fi
	source $FILE
	build
	if [ $PKG == "linux" ]; then
		echo "keepping $PKG build dir"
	else
		if [ -d $SRCS/$PKG ]; then
			echo "cleaning $PKG build dir."
			rm -rf $SRCS/$PKG
		fi
	fi
	echo "$PKG done."
}

build_pkg $@
