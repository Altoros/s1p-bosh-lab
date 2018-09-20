#!/bin/bash -xe
[ -f ~/platform-delivery-update-gcp-turbo.zip ]
PROJECTID="$(gcloud config list --format 'value(core.project)' 2>/dev/null)"
PROJECTENV="sp1-bosh"
MASTERDNSZONENAME="sp1bosh-$PROJECTID"
DNSNAME="yourdns"
EMAIL="sampleuser@altoros.net"

# Manually upload platform-delivery-update-gcp-turbo.zip
[ -e ~/platform-delivery-update-gcp-turbo.zip ] && echo "FOUND ~/platform-delivery-update-gcp-turbo.zip" || echo "please manually upload ~/platform-delivery-update-gcp-turbo.zip"

cd ~
unzip platform-delivery-update-gcp-turbo.zip
cd ~/platform-delivery-update-gcp-turbo/paas-automation

# create terraform file
cat > vars/gcp.env.sh << EOF
# Google account email to authorize with
auth_account='$EMAIL'

# Used to prefix every object
env_name="altoros-automation"

service_account="altoros-automation"

# Name of the GCP Project
gcp_project_name="$(gcloud config list --format 'value(core.project)' 2>/dev/null)"

# GCP Region to use
gcp_region="us-east1"

# GCP Zones list in the region (up to 3 entries in the list).
# Do not modify the order once created. You can add but not delete entries
# Eg for 3 entries: gcp_zones = ["us-east1-b", "us-east1-c", "us-east1-d"]
gcp_zones='["us-east1-b"]'

# The master DNS Zone name (not the actual fqdn, but the name of the resource in GCP)
master_dns_zone_name="$MASTERDNSZONENAME"

# Subdomain of the master zone, which will be created. All entries for Concourse, credhub and UAA will be created in this subdomain.
dns_domain_name="$DNSNAME"

# Must be a /24
bootstrap_subnet="10.0.0.0/24"

# Can be 0.0.0.0/0 for full access or a list of IPs/subnets for restricted access
# The control plane is still behind a jumpbox generated SSH keys and passwords
source_admin_networks='[ "0.0.0.0/0" ]'

# Optional (default is small)
concourse_web_vm_type="small"

# Optional (default is medium)
concourse_worker_vm_type="medium"

# Optional (default is 1): Number of Concourse web VMs to deploy
concourse_web_vm_count=0

# Optional (default is 1): Number of Concourse workers to deploy
concourse_worker_vm_count=0

# Optional (default is false): Debug enabled
debug="false"

# Optional (default is 10): Size of the Database persistent disk
db_persistent_disk_size="10"

# Optional (default is small): Size of the postgres DB VM
db_vm_type="small"

# Optional (default is false): Deploy grafana and influxdb to monitor the solution
deploy_metrics="false"
EOF

cd ~/s1p-bosh-lab/setup-bosh-environment
./deploy_bosh_via_google_cloud_shell.sh
