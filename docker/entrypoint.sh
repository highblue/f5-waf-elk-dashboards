#!/usr/bin/env bash
 
/bin/su -s /bin/bash -c '/opt/f5waf/bin/bd_agent &' nginx
 
/bin/su -s /bin/bash -c "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/bd /usr/share/ts/bin/bd-socket-plugin tmm_count 4 proc_cp
uinfo_cpu_mhz 2000000 total_xml_memory 307200000 total_umu_max_size 3129344 sys_max_account_id 1024 no_static_config 2>&1 > /v
ar/log/f5waf/bd-socket-plugin.log &" nginx
 
/usr/sbin/nginx -g 'daemon off;'
