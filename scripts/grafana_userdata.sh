#!/bin/bash
#download grafana -where to download 
#/opt or /usr ex: /tmp
#https://grafana.com/grafana/download?edition=oss
cd /opt 
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-10.3.1.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-10.3.1.linux-amd64.tar.gz
#permisisons
rm -f  grafana-enterprise-*.tar.gz
chmod -R 755 grafana*
cd grafana*
cd bin 
nohup ./grafana server &
#start 
sudo yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-10.3.1-1.x86_64.rpm
sudo systemctl start  grafana-server