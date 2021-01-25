Centos7 containing:
- Dockerfile to build Nginx App Protect docker image
- attack_sig_updated_Dockerfile to build Nginx App Protect docker image with signature update
- app-protect.repo
-The files located under /home/centos 
-Docker container entrypoint.sh
- Logging profile - log-default.json
- nginx.conf
- policy/default_policy.json
 
Run:
```
- sudo docker build -t nginx_app_protect .
- sudo docker run -itd --name nginx_app_protect_container -v `pwd`/policy:/policy -p 8080:8080 nginx_app_protect
- Press WEB button above to access web browser
- Send attack via URI parameter: /?a=<script>
- Get blocking page.
- Send attack via URI parameter: /wp-admin/admin-post.php?do_reset_wordpress
- The request isn't blocked. (try this again after building a new Docker image with the signature update package) 
- Edit policy file policy/default_policy.json and change 'enforcementMode' from 'blocking' to 'transparent'
- sudo docker exec -it nginx_app_protect_container nginx -s reload
- Send attack via URI parameter: /?a=<script>
- Same request isn't blocked.

To run with updated signatures:
- sudo docker build -t nginx_app_protect -f attack_sig_updated_Dockerfile .
- sudo docker run -itd --name nginx_app_protect_container -v `pwd`/policy:/policy -p 8080:8080 nginx_app_protect
- See that the attack signature package revision datetime log message in /var/log/nginx/error.log has been updated:
APP_PROTECT { "event": "configuration_load_success", "attack_signatures_package":{"revision_datetime":"2020-03-16T14:11:52Z","version":"2020.0316"},"completed_successfully":true}
- Send attack via URI parameter: /wp-admin/admin-post.php?do_reset_wordpress
- Get Blocking page.
```
