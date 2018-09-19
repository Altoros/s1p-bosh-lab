# Setup BOSH environment

### Installing Google Cloud SDK
Cloud SDK runs on Linux, macOS, and Windows. It requires Python 2.7.x. Some tools bundled with Cloud SDK have additional requirements. For example, Java tools for Google App Engine development require Java 1.7 or later.
* [Quickstart for Windows](https://cloud.google.com/sdk/docs/quickstart-windows)
* [Quickstart for macOS](https://cloud.google.com/sdk/docs/quickstart-macos)
* [Quickstart for Linux](https://cloud.google.com/sdk/docs/quickstart-linux)
* [Quickstart for Debian and Ubuntu](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)
* [Quickstart for Red Hat and Centos](https://cloud.google.com/sdk/docs/quickstart-redhat-centos)


### Login to Google Project

### Start Google Cloud Shell
[Starting Cloud Shell](https://cloud.google.com/shell/docs/starting-cloud-shell)

### Clone repo down to your Google Cloud Shell
```
git clone https://github.com/Altoros/s1p-bosh-lab.git
cd s1p-bosh-lab.git
```

### deploy BOSH using Turbo
* Edit the provision_deploy_script.sh
```
vim setup-bosh-environment/provision_deploy_script.sh
DNSNAME="yourdns"
EMAIL="gcptraining@altoros.net"
```
### upload platform-delivery-update-gcp-turbo.zip to your Google Cloud Shell

### RUN provision_deploy_script.sh
```
./provision_deploy_script.sh
```


### SSH into deployed jumpbox
[Regions and Zones](https://cloud.google.com/compute/docs/regions-zones/)
```
gcloud compute --project "YOUR_PROJECT_ID" ssh --zone "yourregion" "yourinstancename"
```

### Switch to ubuntu user
```
sudo su - ubuntu
```

### TEST BOSH Deployment
```
bosh vms
```
