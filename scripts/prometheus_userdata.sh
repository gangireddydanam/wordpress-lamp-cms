#!/bin/bash
#download - extract - start 
cd /opt 
wget https://github.com/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz
cd prometheus-* 
#prometheus.yaml (we have to specify from which all exporters we have to collect data)
# scrape_configs: #collect the data
#   - job_name: 'prometheus'
#     scrape_interval: 5s
#     static_configs:
#       - targets: ['wordpressec2:9090']

#start 
./prometheus 