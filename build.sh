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
export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
export PATH=$PREFIX/bin:$PATH
export CFLAGS=
export CXXFLAGS=
export LDFLAGS=
export CPPFLAGS=
export ACLOCAL_FLAGS=
export LD_LIBRARY_PATH=


cd $ROOT/deps/zlib
env CFLAGS=-fPIC ./configure --static --prefix=$PREFIX
make -j6
make install

ldflags_zlib=`pkg-config --libs-only-L zlib`

cd $ROOT/deps/protobuf
./autogen.sh
./configure --with-pic --enable-static --disable-shared --prefix=$PREFIX
make -j6
make install

cd $ROOT/deps
if [ ! -f ncurses-5.9.tar.gz ]; then
    wget 'http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz' 
fi
rm -rf ncurses-5.9
tar -zxf ncurses-5.9.tar.gz

cd $ROOT/deps/ncurses-5.9
env CFLAGS=-fPIC ./configure --prefix=$PREFIX --without-shared --enable-widec --enable-pc-files
make -j6
make install

cd $ROOT/deps
if [ ! -f perl-5.22.1.tar.gz ]; then
wget 'http://www.cpan.org/src/5.0/perl-5.22.1.tar.gz'
fi
rm -rf $ROOT/deps/perl-5.22.1
tar -zxf perl-5.22.1.tar.gz
cd $ROOT/deps/perl-5.22.1
./Configure -des -Dprefix=$PREFIX
make -j6
make install



cd $ROOT/deps/openssl
./config --prefix=$PREFIX no-shared
make -j6
make install

cd $ROOT/deps/mosh
./autogen.sh
env "LDFLAGS=${ldflags_zlib} -static" ./configure --prefix=$PREFIX
#./configure --prefix=$PREFIX
make
make install
