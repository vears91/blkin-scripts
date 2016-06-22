#!/bin/bash
lttng create $1
lttng enable-event -u zipkin:timestamp
lttng enable-event -u zipkin:keyval_integer
lttng enable-event -u zipkin:keyval_string

lttng start 

LD_PRELOAD=liblttng-ust-fork.so ../src/vstart.sh -n --short

./bin/rados mkpool test-blkin
./bin/rados put test-object-1 ../src/vstart.sh --pool=test-blkin
./bin/rados -p test-blkin ls
./bin/ceph osd map test-blkin test-object-1
./bin/rados get test-object-1 ../src/vstart-copy.sh --pool=test-blkin
md5sum ../src/vstart*
./bin/rados rm test-object-1 --pool=test-blkin

lttng stop
lttng destroy $1