#!/bin/bash
cd ~
if [ -d ./ceph ]
	then
	cd ./ceph
else
	git clone https://github.com/vears91/ceph.git && cd ceph
	git remote add cbodley https://github.com/cbodley/ceph.git
	git remote add upstream https://github.com/ceph/ceph.git
	git fetch origin
	git fetch upstream
	if [ -n "$1" ]
		then
		git checkout $1
	fi
	git submodule update --init --recursive
	./install-deps.sh
fi

if [ -d ./build ]
	then
	cd build
else
	mkdir build && cd build
fi

cmake -DWITH_XIO=OFF -DWITH_BLKIN=ON .. && make -j4 || echo "Build failed"
#cp ../src/vstart.sh ./
#cp ../src/stop.sh ./

