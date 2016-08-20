#!/bin/bash
cd ~/lttng-traces/
rm -rf fio

cd ~/ceph/build-rbd
../src/stop.sh
make -j8 || exit
sudo make install
LD_PRELOAD=liblttng-ust-fork.so ../src/vstart.sh -n -x -d -l --short
./bin/rbd -c ./ceph.conf create --size 1024 fio_test --pool rbd

if [ -d ~/fio ]
	then
	cd ~/fio
else
	cd ~
	git clone https://github.com/axboe/fio && cd ~/fio
fi
LDFLAGS="-L$HOME/ceph/build-rbd/lib -Wl,-rpath,$HOME/ceph/build-rbd/lib" ./configure --extra-cflags="-I/usr/local/include/"
make
lttng create fio -o $HOME/lttng-traces/fio
lttng enable-event -u zipkin:timestamp
lttng enable-event -u zipkin:keyval_integer
lttng enable-event -u zipkin:keyval_string
lttng start

LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH
CEPH_CONF=~/ceph/build-rbd/ceph.conf ./fio ~/rbd.fio &
FIO_PID=$!
sleep 3s
kill $FIO_PID

lttng stop
lttng destroy

cd ~/babeltrace-zipkin/
python3 babeltrace_zipkin.py $HOME/lttng-traces/fio/ust/uid/1000/64-bit/ -s 127.0.0.1 -p 9410
