# Setup BOSH environment

### Installing Google Cloud SDK
Cloud SDK runs on Linux, macOS, and Windows. It requires Python 2.7.x. Some tools bundled with Cloud SDK have additional requirements. For example, Java tools for Google App Engine development require Java 1.7 or later.
* [Quickstart for Windows](https://cloud.google.com/sdk/docs/quickstart-windows)
* [Quickstart for macOS](https://cloud.google.com/sdk/docs/quickstart-macos)
* [Quickstart for Linux](https://cloud.google.com/sdk/docs/quickstart-linux)
* [Quickstart for Debian and Ubuntu](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)
* [Quickstart for Red Hat and Centos](https://cloud.google.com/sdk/docs/quickstart-redhat-centos)


### Login to Google Project
```
gcloud auth login
```

### Set project id
```
gcloud config set project YOUR_PROJECT_ID
```


### deploy devbox -> this may need to done via script

* image: ubuntu-1804-bionic-v20180911
* Machine type: n1-standard-2
* HD Size: 	40GB
* place gcp_credentials_json in home directory
* BOSH Dependancies
```
sudo apt install -y ruby ruby-dev g++ make
```

### SSH into dev server to deploy bosh
[Regions and Zones](https://cloud.google.com/compute/docs/regions-zones/)
```
 gcloud compute --project "YOUR_PROJECT_ID" ssh --zone "yourregion" "yourinstancename"
```

### INSTALL  BOSH
```
curl -LO https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.1.1-linux-amd64
chmod +x bosh-cli-*
sudo mv bosh-cli-* /usr/local/bin/bosh
bosh --version
```

### Configure Setting before BOSH Director creation.
```
# Create directory to keep state
mkdir bosh-1 && cd bosh-1

# Clone Director templates
git clone https://github.com/cloudfoundry/bosh-deployment


# create appropriate filewalls
gcloud compute firewall-rules create allow-external-director --network=default --target-tags=bosh-director --allow=tcp:22,tcp:6868,tcp:25555,tcp:8443
gcloud compute firewall-rules create allow-all-internal-bosh --network=default --source-tags=internal-bosh-rules --allow=tcp,udp,icmp

# Create EXTERNAL_IP address for bosh director
 gcloud compute addresses create bosh-director --region us-east1
 EXTERNAL_IP=$(gcloud compute addresses describe bosh-director --region us-east1 | grep -E  address:  | awk '{print $2}')

# Fill below variables (replace example values) and deploy the Director
IPADDRESSOCTECT=$(hostname -i  | cut -d"." -f1-3)
PROJECTID="YOUR_PROJECT_ID"
GCPCREDS="~/YOUR_JSON_KEY.json"
```

#### Create BOSH director
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

### Delete Bosh Director
***In rare cases you may have to manually delete the VM***
```
rm state.json creds.yml
bosh delete-env bosh-deployment/bosh.yml \
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
