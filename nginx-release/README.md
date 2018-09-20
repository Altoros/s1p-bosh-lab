### Prepare Deployment of Nginx Manifest

(Taken from https://raw.githubusercontent.com/cloudfoundry-community/nginx-release/master/manifests/nginx_ubuntu_centos.yml)

***SSH into jumpbox***
```
gcloud compute --project "project-name" ssh --zone "region" "machinename"
```
***switch to ubuntu user***
```
sudo su - ubuntu
```

***We need to create a development environment for our manifest.***
```
mkdir -p ~/workspace/nginx && cd ~/workspace/nginx
```
***Now we need to prepare a deployment manifest.***
```
touch nginx.yml
```

The deployment manifest is a `.yml` file that defines the components and properties of the deployment. When an engineer initiates a new deployment using the CLI, the Director receives a version of the deployment manifest and creates a new deployment using this manifest.

[Deployment identification](https://bosh.io/docs/deployment-manifest.html#deployment)
  ```
  ---
  name: nginx

  ```
  Note, that in our case this block don't contain `director_uuid` parameter, because we are creating environment and don't have BOSH Director installed yet.

[Releases block](https://bosh.io/docs/deployment-manifest.html#releases)
  ```
  releases:
  - name: nginx
    version: latest
  ```
  This section contains information about the releases, that we are going to use in the deployment. As you can see we are installing the latest `nginx` release. A Cloud Provider Interface (CPI) is an API that the Director uses to interact with an IaaS. A CPI abstracts infrastructure differences from the rest of BOSH. Note, that we are using our precompiled releases here, to speed up deployment.

[Stemcells](https://bosh.io/docs/deployment-manifest.html#releases)
```
stemcells:
- alias: centos
  os: centos-7
  version: latest
- alias: ubuntu
  os: ubuntu-xenial
  version: latest
```
This section contains information about the stemcells, that we are going to use for our images in the deployment. As you can see we are using the latest `centos` and `ubuntu` stemcells.  BOSH produces official stemcells for popular operating systems and infrastructures. For infrastructures that support it, light stemcells are a more efficient way to reference stemcells that we have pre-uploaded and shared within the IaaS.

[Instance Groups ](hhttps://bosh.cloudfoundry.org/docs/terminology/#instance-group)
  ```
  instance_groups:
  ```
  Here we define instance groups which is a collection of  instances tasked to perform same jobs. Each instance group has an associated VM type, persistent disk type, a stemcell and a set of jobs. Instance groups are configured in the deployment manifest.

[Instance Information](https://bosh.io/docs/deployment-manifest.html#disk-pools)  
***name:*** Specifies the name of the instance group.  
***instances:*** Specifies the number instances in the environment.  
***azs:*** Specifies the Availability Zones the instances will use. Which is defined in your cloud config.  
***vm_type:*** Specifies the VM types available to deployments. Which is defined in your cloud config.  
***stemcell:*** Specifies the stemcell name that will be used for the instance. The stemcell is either picked automatically based on the OS name and version provided.  
***networks:*** Specifies the network available to deployments. Which is defined in your cloud config.
```
- name: nginx-centos
 instances: 1
 azs: [ z1 ]
 vm_type: nginx-small
 stemcell: centos
 networks:
 - name: nginx
```

***Jobs:*** Define a list of release jobs required to be run on an instance group. Each instance group must be backed by the software from one or more BOSH releases.  
***name:*** Defines the name of the current job.  
***Properties:*** Define the properties that the release job requires, as defined by the release job in its specification file. Regardless of what properties are set in the manifest, they will be injected into the job’s machine only if they are defined in the specification file.
```
   jobs:
   - name: nginx
     release: nginx
     properties:
       nginx_conf: |
         user nobody vcap; # group vcap can read /var/vcap/store
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
             listen [::]:80 ipv6only=off;
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

***Second instances in instance group***
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
            listen [::]:80 ipv6only=off;
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

[Update Block](https://bosh.io/docs/deployment-manifest/#update):   contains canaries and is important for production environments. Canary instances are instances that are updated before other instances. We can use them as fail-fast mechanism, because any update error in a canary instance will terminate the deployment.
```
update:
  canaries: 1
  max_in_flight: 1
  serial: false
  canary_watch_time: 1000-60000
  update_watch_time: 1000-60000
```

***Upload release to bosh director***
```
 bosh upload-release https://github.com/cloudfoundry-community/nginx-release/releases/download/1.13.12/nginx-release-1.13.12.tgz
```

***Upload Stemcells***
```
bosh upload-stemcell --sha1 16e05e6d0e4fc295767ee60608afcb2f2321adec \
  https://bosh.io/d/stemcells/bosh-google-kvm-centos-7-go_agent?v=3586.42

bosh upload-stemcell --sha1 61eb67dcebc84d4fa818708f79c1e37d811c99e9 \
    https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-xenial-go_agent?v=97.17
```

***Deploy Nginx***
```
bosh deploy -d nginx  nginx.yml
```

***Display VMS***  
As you see ***nginx-ubuntu/23a81ebe-af07-4675-adc3-244153394e4a*** is failing we will troubleshoot that later.
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
***Test Nginx instances***
```
curl -sS 10.0.0.137
<html><title>hello</title><body><h1>Hello ::ffff:10.0.0.3</h1></body></html>
```
