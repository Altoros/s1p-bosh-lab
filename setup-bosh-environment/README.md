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
cd s1p-bosh-lab/setup-bosh-environment
```

### deploy using bbl
The below script will pull down remote dependencies from Debian repo, and other github projects. It will also update ~/.bashrc.
```
./setup_bbl_bosh.sh
```

Once we run this script it will prompt you to run following:
```
bash -l
bbl up
```


We can validate that env variables where set by running following:
```
env|grep -i bbl
BBL_IAAS=gcp
BBL_GCP_REGION=us-east1
```
