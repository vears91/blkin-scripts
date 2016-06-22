if [ -d ./ceph ]
	then
	cd ./ceph
else
	git clone git@github.com:vears91/ceph.git && cd ceph
	git remote add cbodley https://github.com/cbodley/ceph.git
	git fetch origin
	git fetch cbodley
	if [ -n "$1" ]
		then
		git checkout $1
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

