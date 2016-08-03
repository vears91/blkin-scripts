#!/bin/bash

cd ~/lttng-traces/
rm -r rgw

cd ~/ceph/build-rgw
../src/stop.sh
make -j4 || exit
#sudo make install
LD_PRELOAD=liblttng-ust-fork.so ../src/vstart.sh -r -n -x -d -l --short
#./bin/rbd -c ./ceph.conf create --size 1024 rgw_test --pool rbd

#cd ~/rgw
#LDFLAGS="-L$HOME/ceph/build-rbd/lib -Wl,-rpath,$HOME/ceph/build-rbd/lib" ./configure --extra-cflags="-I/usr/local/include/"
#make
lttng create rgw -o $HOME/lttng-traces/rgw
#lttng enable-event -u zipkin:timestamp
#lttng enable-event -u zipkin:keyval_integer
#lttng enable-event -u zipkin:keyval_string
lttng start

curl -D outp -vs -H "X-Auth-User: test" -H "X-Auth-Key: testing" http://127.0.0.1:8000/auth 2>&1
sleep 1s

curl -D outp -vs -H "X-Auth-User: test:tester" -H "X-Auth-Key: testing" http://127.0.0.1:8000/auth 
sleep 3s
AUTHTOKEN=$(cat outp | grep X-Auth-Token | sed -e 's/.*: //')
STOTOKEN=$(cat outp | grep X-Storage-Url | sed -e 's/.*: //')

echo -e $AUTHTOKEN
echo -e $STOTOKEN
 
curl -X PUT -vs -H "Accept:" -H "X-Auth-Token: $AUTHTOKEN" http://127.0.0.1:8000/swift/v1/newk 
sleep 3s
curl -vs -H "Accept:" -H "X-Auth-Token: $AUTHTOKEN" http://127.0.0.1:8000/swift/v1/ 
sleep 1s	
curl -X PUT -vs -H "Content-Length: 9" -H "Accept:" -H "X-Auth-Token: $AUTHTOKEN" http://127.0.0.1:8000/swift/v1/newk/obj -d "text test"
sleep 3s
curl -vs -H "Accept:" -H "X-Auth-Token: $AUTHTOKEN" http://127.0.0.1:8000/swift/v1/newk/obj 
sleep 3s
python3 ~/blkin-scripts/swift.py

lttng stop
lttng destroy

#../src/stop.sh
cd ~/babeltrace-zipkin/
python3 babeltrace_zipkin.py $HOME/lttng-traces/rgw/ust/uid/1000/64-bit/ -s 127.0.0.1 -p 9410
