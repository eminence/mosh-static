#!/bin/sh

set -eu

# Build zlib
ROOT=`pwd`
PREFIX=$ROOT/prefix

echo "Mosh Static root (this directory): $ROOT"
echo "Prefix: $PREFIX"
read -p "Press enter to continue"

git submodule foreach git clean -dfx
rm -rf $PREFIX

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export PATH=$PREFIX/bin:$PATH

ldflags_zlib=`pkg-config --libs-only-L zlib`

cd $ROOT/deps/zlib
env CFLAGS=-fPIC ./configure --static --prefix=$PREFIX
make -j6
make install


cd $ROOT/deps/protobuf
./autogen.sh
./configure --with-pic --enable-static --disable-shared --prefix=$PREFIX
make -j6
make install

cd $ROOT/deps
wget 'http://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz' 
tar -zxf ncurses-6.0.tar.gz

cd $ROOT/deps/ncurses-6.0
./configure --prefix=$PREFIX
make -j6
make install

cd $ROOT/deps/openssl
./config --prefix=$PREFIX no-shared
make -j6
make install

cd $ROOT/deps/mosh
#./autogen.sh
env "LDFLAGS=${ldflags_zlib} -static" ./configure --prefix=$PREFIX
make
make install
