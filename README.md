# ELK based dashboards for F5 WAFs
This is community supported repo providing ELK based dashboards for F5 WAFs.

## How does it work?
ELK stands for elasticsearch, logstash, and kibana. Logstash receives logs from the F5 WAF, normalizes them and stores them in the elasticsearch index. Kibana allows you to visualize and navigate through logs using purpose built dashboards.

## Requirements
The provided Kibana dashboards require a minimum version of 7.4.2. If you are using the provided [docker-compose.yaml](docker-compose.yaml) file, this version requirement is met.

## Installation Overview
It is assumed you will be running ELK using the Quick Start directions below. The template in "logstash/conf.d" will create a new logstash pipeline to ingest logs and store them in elasticsearch. If you use the supplied `docker-compose.yaml`, this template will be copied into the docker container instance for you. Once the WAF logs are being ingested into the index, you will need to import files from the [kibana](kibana/) folder to create all necessary objects including the index pattern, visualization and dashboards.

## Quick Start
### Deploying ELK Stack

**NOTE** 注意安装Docker-ce & docker-compose
再次注意：如果是Ubuntu 18.04版本的话，直接按照官方文档安装最新版1.28.0会出现python lib缺失的问题，目前无workaround。
建议安装1.21版本

以下内容是直接安装
```
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

Use docker-compose to deploy your own ELK stack.
```
$ cd /f5-waf-elk-dashboards
$ docker-compose -f docker-compose.yaml up -d
```

---
**NOTE**

这个地方还是需要注意下，我的虚拟机初始设定为4GB内存，后来一直无法启动；后改成8GB也一直限定4GB，所以需要使用如下的方式修改内存限制。
直接修改
sysctl -w vm.max_map_count=262144
如果有问题，直接在conf文件中增加上面那句
/etc/sysctl.conf
重启后检查是否成功：
sysctl vm.max_map_count

The ELK stack docker container will likely exceed the default host's virtual memory system limits. Use [these directions](https://www.elastic.co/guide/en/elasticsearch/reference/5.0/vm-max-map-count.html#vm-max-map-count) to increase this limit on the docker host machine. If you do not, the ELK container will continually restart itself and never fully initialize.

---

容器起来以后，注意看下系统时间和容器内的时间是否一致，否则ELK查询时候会出现时间不对。

docker exec -it <container name> /bin/bash
cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
#设定时区
date 确认时间

### Dashboards Installation
Import dashboards to kibana through UI (Kibana->Management->Saved Objects) or use API calls below.

```
cd /f5-waf-elk-dashboards 
export KIBANA_URL=https://your.kibana:5601
# 这里我将https 改成了http

jq -s . kibana/overview-dashboard.ndjson | jq '{"objects": . }' | \
curl -k --location --request POST "$KIBANA_URL/api/kibana/dashboards/import" \
    --header 'kbn-xsrf: true' \
    --header 'Content-Type: text/plain' -d @- \
    | jq

jq -s . kibana/false-positives-dashboards.ndjson | jq '{"objects": . }' | \
curl -k --location --request POST "$KIBANA_URL/api/kibana/dashboards/import" \
    --header 'kbn-xsrf: true' \
    --header 'Content-Type: text/plain' -d @- \
    | jq
```
### NGINX App Protect Configuration
NGINX App Protect doesn't require any special logging configuration besides logging destination should point to the logstash instance. Take a look to official docs for [examples](https://docs.nginx.com/nginx-app-protect/admin-guide/#centos-7-4-installation)

**NOTE**
The logstash listener in this solution is configured to listen for TCP syslog messages on a custom port (5144). If you have deployed NGINX App Protect on an SELinux protected system (such has Red Hat or CentOS), you will need to configure SELinux to allow remote syslog messages on a custom port. See the [configuration instructions](https://docs.nginx.com/nginx-app-protect/admin-guide/#syslog-to-custom-port) for an example of how to accomplish this.

### BIG-IP Configuration
BIG-IP logging profile must be configured to use "splunk" logging format.
```
# tmsh list security log profile LOG_TO_ELK

security log profile LOG_TO_ELK {
    application {
            ...omitted...
            remote-storage splunk
            servers {
                logstash.domain:logstash-port { }
            }
        }
    }
}
```
## Supported WAFs
* NGINX App Protect
* BIG-IP ASM, Advanced WAF
## Screenshots
### Overview Dashboard
![screenshot1](https://user-images.githubusercontent.com/23067500/72393114-c7c25080-36e6-11ea-81c4-655f4c936476.png)
![screenshot2](https://user-images.githubusercontent.com/23067500/72392972-4cf93580-36e6-11ea-8392-1b80d59b8276.png)
![screenshot3](https://user-images.githubusercontent.com/23067500/72392979-4ff42600-36e6-11ea-9cb9-22b8ba737de0.png)
### False Positives Dashboard
![screenshot1](https://user-images.githubusercontent.com/23067500/81446488-d6b68e00-912f-11ea-9f60-0821c2010e46.png)
![screenshot2](https://user-images.githubusercontent.com/23067500/81446490-d918e800-912f-11ea-9223-a3cf7818cdcf.png)
![screenshot3](https://user-images.githubusercontent.com/23067500/81446492-dae2ab80-912f-11ea-94a2-e99fd7423883.png)
