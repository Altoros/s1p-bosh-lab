# BOSH ADDON OVERVIEW
### Lets dissect the BOSH director deployment
* [state file](https://github.com/tosin2013/altoros_bosh_training/blob/master/bosh-addon-overview/bosh-state-file.md)
* [creds.yml](https://github.com/tosin2013/altoros_bosh_training/blob/master/bosh-addon-overview/bosh-creds-file.md)
* [vars](https://github.com/tosin2013/altoros_bosh_training/blob/master/bosh-addon-overview/bosh-variables.md)
* [operations file](https://github.com/tosin2013/altoros_bosh_training/blob/master/bosh-addon-overview/bosh-operations-file.md)


```
bosh create-env bosh-deployment/bosh.yml \
    --state=state.json \
    --vars-store=creds.yml \
    -o bosh-deployment/gcp/cpi.yml \
    -o bosh-deployment/jumpbox-user.yml \
    -o bosh-deployment/misc/ntp.yml \
    -o bosh-deployment/uaa.yml \
    -o bosh-deployment/credhub.yml \
    -o bosh-deployment/misc/dns.yml \
    -o bosh-deployment/external-ip-not-recommended.yml \
    -v director_name=bosh-1 \
    -v internal_cidr=${IPADDRESSOCTECT}.0/24 \
    -v internal_gw=${IPADDRESSOCTECT}.1 \
    -v internal_ip=${IPADDRESSOCTECT}.6 \
    --var-file gcp_credentials_json=${GCPCREDS} \
    -v project_id=$PROJECTID \
    -v zone=us-east1-c \
    -v tags=[bosh-director,internal-bosh-rules] \
    -v network=default \
    -v subnetwork=default \
    -v internal_ntp=[metadata.google.internal] \
    -v internal_dns=[8.8.8.8,8.8.4.4] \
    -v external_ip=$EXTERNAL_IP
```

### Lets dissect the BOSH Release for jumpbox
Deployment manifest (or just manifest)
A YAML file that identifies one or more releases, stemcells and specifies how to configure them for a given deployment.
[Link](https://bosh.io/docs/terminology/#manifest)

* [name]()
* [instance_groups]()
* [properties]()
* [update]()
* [stemcells]()
* [releases]()

```
bosh -e <env> -d jumpbox deploy manifests/jumpbox.yml

~/workspace/jumpbox-boshrelease$ cat manifests/jumpbox.yml
name: jumpbox-ci

instance_groups:
- name: jumpbox
  instances: 1
  azs:       [z1]
  vm_type:   default
  stemcell:  default
  networks:
    - name: default
  jobs:
    - { release: jumpbox, name: jumpbox }
    - { release: jumpbox, name: inventory }

properties:
  jumpbox:
    env:
      FOO: BAR
    users:
      - name: demouser
      - name: demouser2
        shell: /bin/sh
    delete:
      - demouser3

update:
  canaries: 0
  max_in_flight: 1
  serial: true
  canary_watch_time: 1000-120000
  update_watch_time: 1000-120000

stemcells:
- alias: default
  os: ubuntu-trusty
  version: latest

releases:
- name: jumpbox
  version: 4.4.5
  url: https://github.com/cloudfoundry-community/jumpbox-boshrelease/releases/download/v4.4.5/jumpbox-4.4.5.tgz
  sha1: f22f5456658405cd46d7dcad9952e6bbdd4da27e
  ```

[BOSH Terminology](https://bosh.io/docs/terminology/)  
[Deployment State](https://bosh.io/docs/cli-envs/#deployment-state)
