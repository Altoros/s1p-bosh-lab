#!/usr/bin/env bash
#
# Description: Idempotent installation of BOSH, Concourse CI/CD and pipelines
# for PaaS automation of Cloud Foundry and Kubernetes on GCP
# Written by: Ryan Meharg - ryan.meharg@altoros.com
#
# -e          - fail on errors
# -u          - ensure all variables are set
# -o pipeline - catch pipeed command failures
# -x          - verbose when `export DEBUG=true` is set on shell
#
# read -n 1 -s -r -p "Press any key to continue"

set -eu
set -o pipefail
[[ -z "${DEBUG:-""}" ]] || set -x

clear
echo "---------------------"
echo "PAAS Automation - GCP"
echo "---------------------"
echo

cd ~/platform-delivery-update-gcp-turbo/paas-automation

source vars/gcp.env.sh

mkdir -p environments/gcp

mkdir -p deployments
pushd deployments

set +e


  if [ -z "$(which terraform)" ]; then
    echo
    echo "Installing terraform..."
    TERRAFORMVERSION="0.11.8"
    curl -OL https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_linux_amd64.zip
    unzip terraform_${TERRAFORMVERSION}_linux_amd64.zip
    sudo mv terraform  /usr/local/bin/terraform
  fi

pushd cf
  if [ -z "$(which credhub)" ]; then
    echo
    echo "Installing credhub-cli..."
    curl -OL https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.0.0/credhub-linux-2.0.0.tgz
    tar -zxvf credhub-linux-2.0.0.tgz
    sudo mv credhub /usr/local/bin/credhub
  fi

  if [ -z "$(which uaac)" ]; then
    echo "Installing UAAC..." >&2
    sudo git clone "https://github.com/cloudfoundry/cf-uaac.git" ~/cf-uaac && \
    cd ~/cf-uaac && sudo gem install bundler && sudo bundle install && sudo gem build cf-uaac.gemspec
    sudo gem install cf-uaac*.gem && sudo gem install cf-uaac
  fi
popd

  if [ -z "$(which bosh)" ]; then
    echo "Installing bosh CLI..." >&2
    curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
    | grep browser_download_url \
    | grep linux-amd64 \
    | cut -d '"' -f 4 \
    | wget -qi - -O bosh
    sudo chmod +x bosh && sudo mv bosh /usr/local/bin/bosh
  fi

set -e

pushd deployments
echo
echo "Creating GCP service account..."
set +e
  gcloud iam service-accounts create $service_account --display-name "Altoros Automation"
  gcloud iam service-accounts keys create "../environments/gcp/terraform-key.json" --iam-account "$service_account@$gcp_project_name.iam.gserviceaccount.com"
  gcloud projects add-iam-policy-binding $gcp_project_name --member "serviceAccount:$service_account@$gcp_project_name.iam.gserviceaccount.com" --role "roles/editor"
set -e

echo
echo "Enabling Google APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

echo
echo "Cloning terraform scripts..."
if pushd terraform-turbo; then git reset --hard && popd; else git clone https://github.com/pivotalservices/turbo.git terraform-turbo; fi

pushd terraform-turbo
  git fetch --tags
  latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
  git checkout "$latestTag"
  git submodule sync
  git submodule update --init --recursive
popd

export TF_VAR_gcp_key=$(cat ../environments/gcp/terraform-key.json)

echo
echo "Creating tfvars file..."
pushd terraform-turbo/terraform/gcp

cat << EOF > terraform.tfvars
# Used to prefix every object
env_name = "$env_name"

# Name of the GCP Project
gcp_project_name = "$gcp_project_name"

# GCP Region to use
gcp_region = "$gcp_region"

# GCP Zones list in the region (up to 3 entries in the list).
# Do not modify the order once created. You can add but not delete entries
# Eg for 3 entries: gcp_zones = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
gcp_zones = $gcp_zones

# The master DNS Zone name (not the actual fqdn, but the name of the resource in GCP)
master_dns_zone_name = "$master_dns_zone_name"

# Subdomain of the master zone, which will be created. All entries for Concourse, credhub and UAA will be created in this subdomain.
dns_domain_name = "$dns_domain_name"

# Must be a /24
bootstrap_subnet = "$bootstrap_subnet"

# Can be 0.0.0.0/0 for full access or a list of IPs/subnets for restricted access
# The control plane is still behind a jumpbox generated SSH keys and passwords
source_admin_networks = $source_admin_networks

# Optional (default is small)
concourse_web_vm_type = "$concourse_web_vm_type"

# Optional (default is medium)
concourse_worker_vm_type = "$concourse_worker_vm_type"

# Optional (default is 1): Number of Concourse web VMs to deploy
concourse_web_vm_count = $concourse_web_vm_count

# Optional (default is 1): Number of Concourse workers to deploy
concourse_worker_vm_count = $concourse_worker_vm_count

# Optional (default is false): Debug enabled
debug = "$debug"

# Optional (default is 10): Size of the Database persistent disk
db_persistent_disk_size = "$db_persistent_disk_size"

# Optional (default is small): Size of the postgres DB VM
db_vm_type = "$db_vm_type"

# Optional (default is false): Deploy grafana and influxdb to monitor the solution
deploy_metrics = "$deploy_metrics"
EOF

echo
echo "Running terraform..."
terraform init
terraform plan -out gcp-env-plan
terraform apply gcp-env-plan

echo
echo "Copying terraform state and scripts..."
cp terraform.tfstate ../../../../environments/gcp/
cp terraform.tfvars ../../../../environments/gcp/
cp ../../bin/* ../../../../environments/gcp/
