# Create bosh release

For other exercises we will be stepping out of our deployment directory and we will only have one deployment, so we will do something to facilitate progress.

Create file `~/.envrc` and add following content.

```file:~/.envrc
pushd s1p-bosh-lab/setup-bosh-environment/
  if [ -f bbl-state.json ]; then
    eval "$(bbl print-env)"
  fi
popd
```

### Initialize an empty release

Run the following commands to intialize a new release:
```exec
mkdir   ~/greeter-release
cd ~/greeter-release
bosh init-release
```

After executing this command, the filesystem tree should look like this:

```
$ tree
.
├── blobs
├── config
│   └── blobs.yml
├── jobs
├── packages
└── src
```

### Create a router job

Create a router job with:
```exec
cd ~/greeter-release
bosh generate-job router
```

After executing this command, the filesystem tree should look like this:

```
$ tree
.
├── blobs
├── config
│   └── blobs.yml
├── jobs
│   └── router
│       ├── monit
│       ├── spec
│       └── templates
├── packages
└── src
```

### Update the router spec

Open the file `jobs/router/spec` in a text editor and add the following content to it:

```file=~/greeter-release/jobs/router/spec
---
name: router
templates:
  ctl: bin/ctl
  config.yml.erb: config/config.yml

packages:
- greeter
- ruby

properties:
  port:
    description: "Port on which server is listening"
    default: 8080
  upstreams:
    description: "List of upstreams to proxy requests"
    default: []
```

### Update the router Monit config

Open the file `jobs/router/monit` in a text editor and add the following content to it:

```file=~/greeter-release/jobs/router/monit
check process router
  with pidfile /var/vcap/sys/run/router/router.pid
  start program "/var/vcap/jobs/router/bin/ctl start"
  stop program "/var/vcap/jobs/router/bin/ctl stop"
  group vcap
```

### Create the router startup script

Open the file `jobs/router/templates/ctl` in a text editor and add the following content to it:

```file=~/greeter-release/jobs/router/templates/ctl
#!/bin/bash

RUN_DIR=/var/vcap/sys/run/router
LOG_DIR=/var/vcap/sys/log/router

PIDFILE=$RUN_DIR/router.pid
RUNAS=vcap

export PATH=/var/vcap/packages/ruby/bin:$PATH
export BUNDLE_GEMFILE=/var/vcap/packages/greeter/Gemfile
export GEM_HOME=/var/vcap/packages/greeter/gem_home/ruby/2.3.0

function pid_exists() {
  ps -p $1 &> /dev/null
}

case $1 in

  start)
    mkdir -p $RUN_DIR $LOG_DIR
    chown -R $RUNAS:$RUNAS $RUN_DIR $LOG_DIR

    echo $$ > $PIDFILE

    export CONFIG_FILE=/var/vcap/jobs/router/config/config.yml

    exec chpst -u $RUNAS:$RUNAS \
      bundle exec ruby /var/vcap/packages/greeter/router.rb \
      -p <%= p("port") %> \
      -o 0.0.0.0 \
      >>$LOG_DIR/server.stdout.log 2>>$LOG_DIR/server.stderr.log
    ;;

  stop)
    PID=$(head -1 $PIDFILE)
    if [ ! -z $PID ] && pid_exists $PID; then
      kill $PID
    fi
    while [ -e /proc/$PID ]; do sleep 0.1; done
    rm -f $PIDFILE
    ;;

  *)
  echo "Usage: ctl {start|stop}" ;;
esac
exit 0
```

### Create the router config template

Create a config template for the router by opening the file `jobs/router/templates/config.yml.erb` and adding the following lines to it:

```file=~/greeter-release/jobs/router/templates/config.yml.erb
---
upstreams: <%= p('upstreams') %>
```

### Create the app job

Generate a job:

```exec
cd ~/greeter-release
bosh generate-job app
```

After executing this command, the file system tree should look similar to this:

```
$ tree
.
├── blobs
├── config
│   └── blobs.yml
├── jobs
│   ├── router
│   │   ├── monit
│   │   ├── spec
│   │   └── templates
│   └── app
│       ├── monit
│       ├── spec
│       └── templates
├── packages
└── src
```

### Update the app spec

Open the file `jobs/app/spec` in a text editor and add the following lines:

```file=~/greeter-release/jobs/app/spec
---
name: app
templates:
  ctl: bin/ctl

packages:
- greeter
- ruby

properties:
  port:
    description: "Port on which server is listening"
    default: 8080
```

### Update the app Monit config

Open the file `jobs/app/monit` and add the following lines:

```file=~/greeter-release/jobs/app/monit
check process app
  with pidfile /var/vcap/sys/run/app/app.pid
  start program "/var/vcap/jobs/app/bin/ctl start"
  stop program "/var/vcap/jobs/app/bin/ctl stop"
  group vcap
```

### Create the app startup script

Open the file `jobs/app/templates/ctl` in a text editor and add the following content to it:

```file=~/greeter-release/jobs/app/templates/ctl
#!/bin/bash

RUN_DIR=/var/vcap/sys/run/app
LOG_DIR=/var/vcap/sys/log/app

PIDFILE=$RUN_DIR/app.pid
RUNAS=vcap

export PATH=/var/vcap/packages/ruby/bin:$PATH
export BUNDLE_GEMFILE=/var/vcap/packages/greeter/Gemfile
export GEM_HOME=/var/vcap/packages/greeter/gem_home/ruby/2.3.0

function pid_exists() {
  ps -p $1 &> /dev/null
}

case $1 in
  start)
    mkdir -p $RUN_DIR $LOG_DIR
    chown -R $RUNAS:$RUNAS $RUN_DIR $LOG_DIR

    echo $$ > $PIDFILE

    exec chpst -u $RUNAS:$RUNAS \
      bundle exec ruby /var/vcap/packages/greeter/app.rb \
      -p <%= p("port") %> \
      -o 0.0.0.0 \
      >>$LOG_DIR/server.stdout.log 2>>$LOG_DIR/server.stderr.log
    ;;

  stop)
    PID=$(head -1 $PIDFILE)
    if [ ! -z $PID ] && pid_exists $PID; then
      kill $PID
    fi
    while [ -e /proc/$PID ]; do sleep 0.1; done
    rm -f $PIDFILE
    ;;

  *)
  echo "Usage: ctl {start|stop}" ;;
esac
exit 0
```

### Create the Ruby package

Generate the Ruby package:
```exec
cd ~/greeter-release
bosh generate-package ruby
```

After executing this command, the filesystem tree should look similar to this:

```
$ tree
.
├── blobs
├── config
│   └── blobs.yml
├── creating_this_bosh_release.md
├── jobs
│   ├── app
│   │   ├── monit
│   │   ├── spec
│   │   └── templates
│   │       └── ctl
│   └── router
│       ├── monit
│       ├── spec
│       └── templates
│           ├── config.json.erb
│           └── ctl
├── packages
│   └── ruby
│       ├── packaging
│       └── spec
└── src
```

### Create the Ruby spec

Open the file `packages/ruby/spec` in a text editor and add the following lines to it:

```file=~/greeter-release/packages/ruby/spec
---
name: ruby
files:
- ruby/ruby-2.3.0.tar.gz
- ruby/bundler-1.11.2.gem
```

### Create the Ruby packaging script

Edit the following file `packages/ruby/packaging` and add the following content to it:

```file=~/greeter-release/packages/ruby/packaging
set -e

tar xzf ruby/ruby-2.3.0.tar.gz
(
  set -e
  cd ruby-2.3.0
  LDFLAGS="-Wl,-rpath -Wl,${BOSH_INSTALL_TARGET}" CFLAGS='-fPIC' ./configure --prefix=${BOSH_INSTALL_TARGET} --disable-install-doc --with-opt-dir=${BOSH_INSTALL_TARGET} --without-gmp
  make
  make install
)

${BOSH_INSTALL_TARGET}/bin/gem install ruby/bundler-1.11.2.gem --local --no-ri --no-rdoc
```

### Download Ruby sources

```exec
cd ~/greeter-release
mkdir ~/packages/
curl https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz --create-dirs -o ~/packages/ruby-2.3.0.tar.gz
curl https://rubygems.org/downloads/bundler-1.11.2.gem --create-dirs -o ~/packages/bundler-1.11.2.gem

bosh add-blob ~/packages/ruby-2.3.0.tar.gz ruby/ruby-2.3.0.tar.gz
bosh add-blob ~/packages/bundler-1.11.2.gem ruby/bundler-1.11.2.gem
```

### Create the greeter package

Generate the greeter package with:
```exec
cd ~/greeter-release
bosh generate-package greeter
```

After executing this command, the filesystem tree should look similar to this:

```
$ tree
.
├── blobs
├── config
│   └── blobs.yml
├── creating_this_bosh_release.md
├── jobs
│   ├── app
│   │   ├── monit
│   │   ├── spec
│   │   └── templates
│   │       └── ctl
│   └── router
│       ├── monit
│       ├── spec
│       └── templates
│           ├── config.json.erb
│           └── ctl
├── packages
│   ├── ruby
│   │   ├── packaging
│   │   └── spec
│   └── greeter
│       ├── packaging
│       └── spec
└── src
```

### Create the greeter spec

Edit the file `packages/greeter/spec` and add the following content to it:

```file=~/greeter-release/packages/greeter/spec
---
name: greeter
dependencies:
- ruby
files:
- greeter/**/*
```

### Create the greeter packaging script

Edit the file `packages/greeter/packaging` and add the following content to it:

```file=~/greeter-release/packages/greeter/packaging
set -e

cp -r greeter/* ${BOSH_INSTALL_TARGET}

cd ${BOSH_INSTALL_TARGET}

find .

mkdir -p ${BOSH_INSTALL_TARGET}/gem_home

/var/vcap/packages/ruby/bin/bundle install --local --no-prune --path ${BOSH_INSTALL_TARGET}/gem_home
```

## Download greeter sources

Donload greeter sources with:
```exec
apt-get install git
git clone https://github.com/Altoros/greeter.git ~/greeter-release/src/greeter
```

### Configure the blobstore

Save the following file as `config/final.yml`:

```file=~/greeter-release/config/final.yml
---
final_name: greeter-release
blobstore:
  provider: local
  options:
    blobstore_path: /tmp/bosh-blobstore
```

### Generate the deployment manifest

Save the following as `~/greeter-release/greeter.yml`:

```file=~/greeter-release/greeter.yml
---
name: greeter-release

releases:
- name: greeter-release
  version: latest

stemcells:
- alias: default
  os: ubuntu-trusty
  version: latest

update:
  canaries: 1
  max_in_flight: 10
  canary_watch_time: 1000-30000
  update_watch_time: 1000-30000
  vm_strategy: create-swap-delete


instance_groups:
- name: app
  azs:
  - z2
  instances: 1
  vm_type: minimal
  stemcell: default
  update:
    serial: true
  networks:
  - name: private
    static_ips:
    - 10.0.255.7
  jobs:
  - name: app
    release: greeter-release
    properties: {}
- name: router
  azs:
  - z1
  instances: 1
  vm_type: minimal
  stemcell: default
  update:
    serial: true
  networks:
  - name: private
    static_ips:
    - 10.0.255.8
  jobs:
  - name: router
    release: greeter-release
    properties:
      upstreams:
        - 10.0.255.7:8080
```

### Create the release

Create a release by running:
```exec
cd ~/greeter-release
bosh create-release --force
bosh upload-release
```

### Upload stemcell

If you haven't done this before, upload a stemcell with:

```exec
# Ubuntu trusty
bosh_cmd=$(curl -s https://bosh.io/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent|grep -A2 "bosh upload-stemcell"|sed -e 's/<div.*<pre>//g' -e 's/<a.*">//g' -e 's/<\/a>.*$//g' -e 's/\\//g' |tr -d '\n')
eval $bosh_cmd
```

### Deploy!

Finally, everything is ready for deployment:

```exec
bosh -d greeter-release -n  deploy greeter.yml
```

Let's check if everything has been deployed as intended:
```exec
curl "http://{{source ~/deployment/vars && echo $eip_greeter}}:8080"
```

To list all your VMs, execute this command:
```exec
bosh vms
```

To ssh to various systems in this env please look at this [bbl ssh and bosh ssh](https://github.com/cloudfoundry/bosh-bootloader/blob/master/docs/howto-ssh.md)

### Add external ip to your deployment
gcloud beta compute addresses create router-ip  --region=us-east1 --network-tier=PREMIUM

gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address'

## cloud config update
```file:cloud-config/ops.yml
- type: replace
  path: /networks/-
  value:
    name: public
    type: vip
```

## After we added
```
- type: replace
  path: /vm_extensions/-
  value:
     name: gcp-tag
     cloud_properties:
       tags: [router-ip-open]
```       

```
bosh update-cloud-config <(bosh int cloud-config/cloud-config.yml -o cloud-config/ops.yml ) -l vars/cloud-config-vars.yml
```


## greeting app
```
bosh -d greeter-release -n  deploy greeter.yml -o ops-ip.yml -v external_ip=$(gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address')
```

for the moment inside of setup folder
```
gcloud compute firewall-rules create allow-router-http --direction=INGRESS --priority=1000 --network=$(bosh int vars/director-vars-file.yml --path /network) --action=ALLOW --rules=tcp:8080 --source-ranges=0.0.0.0/0 --target-tags=router
```

```
curl $(gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address'):8080
```


###  Scale your deployment

In your `~/deployment/greeter.yml` manifest:

1. Add the `10.0.0.9` IP to the private static pool `/networks/name=private/subnets/gateway=10.0.0.1/static/-`
1. Add the `10.0.0.9` IP from the private static pool to `/jobs/name=app/networks/name=private/static_ips/-`
1. Increase the number of instances in `/jobs/name=app/instances` by 1
1. Append `10.0.0.9:8080` to the `/jobs/name=router/properties/upstreams/-` array


The best way to do this is to create an opfile. We are leaving the creation of such file as an excesse to the users. Another option s to update the manifest manually.
Note, that when identifying properties path we use the same syntax, as it is used in opfiles, so them can be copied directly.

Deploy once again:

```exec
bosh  -d greeter-release -n  deploy -o ~/deployment/greeter-opfile.yml ~/deployment/greeter.yml
```

And if you `curl` the router multiple times, you should see greetings from different upstreams:

```exec
curl "http://{{source ~/deployment/vars && echo $eip_greeter}}:8080"
```
