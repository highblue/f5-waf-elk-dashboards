FROM centos:7.4.1708
 
COPY app-protect.repo /etc/yum.repos.d/

RUN yum install -y epel-release && \
yum install -y app-protect && \
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig && \
mkdir -p /root

COPY nginx.conf /etc/nginx/
COPY entrypoint.sh /root
COPY log-default.json /etc/nginx
 
CMD ["/root/entrypoint.sh"]
