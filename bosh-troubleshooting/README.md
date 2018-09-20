# BOSH TROUBLESHOOTING

### Troubleshooting the nginx deployment

***Remember the nginx deployment***
```
$ bosh vms
Using environment '10.0.0.70' as client 'admin'

Task 35
Task 36
Task 35 done

Task 36 done

Deployment 'nginx'

Instance                                           Process State  AZ  IPs         VM CID                                   VM Type      Active
nginx-centos/94e82144-f161-4f12-af2f-5c0dd55df24e  running        z1  10.0.0.137  vm-28a4e3e9-802e-4bfe-7cef-bc2c8813f136  nginx-small  false
nginx-ubuntu/23a81ebe-af07-4675-adc3-244153394e4a  failing        z1  10.0.0.138  vm-a0de1797-3905-446f-7209-308d7ce52612  nginx-small  false

2 vms

Deployment 'ucc'

Instance                                 Process State  AZ  IPs         VM CID                                   VM Type   Active
db/30d9216e-38a0-4645-bad7-cc7ae8fbca27  running        z1  10.0.0.134  vm-7f793f9c-f0b7-49b5-7fc7-0cc07fb17c84  db-small  false

1 vms

Succeeded
```

***Lets check the processes using BOSH***
```
$ bosh instances --ps
Using environment '10.0.0.70' as client 'admin'

Task 39
Task 40
Task 39 done

Task 40 done

Deployment 'nginx'

Instance                                           Process  Process State  AZ  IPs
nginx-centos/94e82144-f161-4f12-af2f-5c0dd55df24e  -        running        z1  10.0.0.137
~                                                  nginx    running        -   -
nginx-ubuntu/23a81ebe-af07-4675-adc3-244153394e4a  -        failing        z1  10.0.0.138
~                                                  nginx    unknown        -   -

4 instances

Deployment 'ucc'

Instance                                 Process     Process State  AZ  IPs
db/30d9216e-38a0-4645-bad7-cc7ae8fbca27  -           running        z1  10.0.0.134
~                                        pg_janitor  running        -   -
~                                        postgres    running        -   -

3 instances

Succeeded
```

***Lets check the logs on the server***

```
$ bosh ssh -d nginx nginx-ubuntu/0
$ sudo su -
$ cd /var/vcap/sys/log/nginx/
$ cat error.log
2018/09/20 23:07:32 [emerg] 4590#4590: socket() [::]:80 failed (97: Address family not supported by protocol)
2018/09/20 23:08:02 [emerg] 4622#4622: socket() [::]:80 failed (97: Address family not supported by protocol)
2018/09/20 23:08:43 [emerg] 4657#4657: socket() [::]:80 failed (97: Address family not supported by protocol)
2018/09/20 23:09:23 [emerg] 4669#4669: socket() [::]:80 failed (97: Address family not supported by protocol)
2018/09/20 23:10:03 [emerg] 4675#4675: socket() [::]:80 failed (97: Address family not supported by protocol)
2018/09/20 23:10:43 [emerg] 4683#4683: socket() [::]:80 failed (97: Address family not supported by protocol)
$ exit
```

***lets edit the nginx.yml***
```
- name: nginx-ubuntu
  instances: 1
  azs: [ z1 ]
  vm_type: nginx-small
  stemcell: ubuntu
  networks:
  - name: nginx
  jobs:
  - name: nginx
    release: nginx
    properties:
      nginx_conf: |
        worker_processes  1;
        error_log /var/vcap/sys/log/nginx/error.log   info;
        #pid        logs/nginx.pid; # PIDFILE is configured via monit's ctl
        events {
          worker_connections  1024;
        }
        http {
          include /var/vcap/packages/nginx/conf/mime.types;
          default_type  application/octet-stream;
          sendfile        on;
          ssi on;
          keepalive_timeout  65;
          server_names_hash_bucket_size 64;
          server {
            server_name _; # invalid value which will never trigger on a real hostname.
            #listen [::]:80 ipv6only=off;
            access_log /var/vcap/sys/log/nginx/toto-access.log;
            error_log /var/vcap/sys/log/nginx/toto-error.log;
          }
          root /var/vcap/store/nginx;
          index index.shtml index.html index.htm;
        }
      pre_start: |
        #!/bin/bash -ex
        NGINX_DIR=/var/vcap/store/nginx
        if [ ! -d $NGINX_DIR ]; then
          mkdir -p $NGINX_DIR
          cd $NGINX_DIR
          echo  '<html><title>hello</title><body><h1>Hello <!--#echo var="REMOTE_ADDR" --></h1></body></html>' > index.shtml
        fi
```

***Lets restart the nginx deployment***
```
$ bosh deploy -d nginx  nginx.yml
bosh vms
Using environment '10.0.0.70' as client 'admin'

Task 48
Task 49
Task 48 done

Task 49 done

Deployment 'nginx'

Instance                                           Process State  AZ  IPs         VM CID                                   VM Type      Active
nginx-centos/94e82144-f161-4f12-af2f-5c0dd55df24e  running        z1  10.0.0.137  vm-28a4e3e9-802e-4bfe-7cef-bc2c8813f136  nginx-small  false
nginx-ubuntu/23a81ebe-af07-4675-adc3-244153394e4a  running        z1  10.0.0.138  vm-16c0a133-1b92-4251-46c3-1311bd64f3dd  nginx-small  false

2 vms

Deployment 'ucc'

Instance                                 Process State  AZ  IPs         VM CID                                   VM Type   Active
db/30d9216e-38a0-4645-bad7-cc7ae8fbca27  running        z1  10.0.0.134  vm-7f793f9c-f0b7-49b5-7fc7-0cc07fb17c84  db-small  false

1 vms

Succeeded
```

***Lets test the result***
```
$ curl 10.0.0.138
<html><title>hello</title><body><h1>Hello 10.0.0.3</h1></body></html>
```
### Troubleshooting the logsearch deployment

### Other BOSH Troubleshooting TIPS
