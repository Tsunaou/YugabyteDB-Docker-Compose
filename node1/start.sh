#!/bin/bash
mkdir -p /opt/data/disk1
mkdir -p /opt/data/disk2
/opt/yugabyte-2.17.2.0/bin/yb-master --flagfile /opt/node/master.conf >& /opt/data/disk1/yb-master.out &
/opt/yugabyte-2.17.2.0/bin/yb-tserver --flagfile /opt/node/tserver.conf
