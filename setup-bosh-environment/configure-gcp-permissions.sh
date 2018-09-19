#!/bin/bash -xe

echo "Creating a file called bosh-director-role.yml."
cat > bosh-director-role.yml << YAML
title: BOSH Director
stage: BETA
description: Allows BOSH Google CPI to perform all BOSH Director actions
name: projects/((project_id))/roles/bosh.director
included_permissions:
# addresses
- compute.addresses.get
- compute.addresses.list

# backend services
- compute.backendServices.get
- compute.backendServices.list

# disk types
- compute.diskTypes.get

# disks
- compute.disks.delete
- compute.disks.list
- compute.disks.get
- compute.disks.createSnapshot
- compute.snapshots.create
- compute.disks.create
- compute.images.useReadOnly

# global operations
- compute.globalOperations.get
# images
- compute.images.delete
- compute.images.get
- compute.images.create

# instance groups
- compute.instanceGroups.get
- compute.instanceGroups.list
- compute.instanceGroups.update

# instances
- compute.instances.setMetadata
- compute.instances.setLabels
- compute.instances.setTags
- compute.instances.reset
- compute.instances.start
- compute.instances.list
- compute.instances.get
- compute.instances.delete
- compute.instances.create
- compute.subnetworks.use
- compute.subnetworks.useExternalIp
- compute.instances.detachDisk
- compute.instances.attachDisk
- compute.disks.use
- compute.instances.deleteAccessConfig
- compute.instances.addAccessConfig
- compute.addresses.use

# machine type
- compute.machineTypes.get

# region operations
- compute.regionOperations.get

# zone operations
- compute.zoneOperations.get

# networks
- compute.networks.get

# subnetworks
- compute.subnetworks.get

# snapshots
- compute.snapshots.delete
- compute.snapshots.get

# target pool
- compute.targetPools.list
- compute.targetPools.get
- compute.targetPools.addInstance
- compute.targetPools.removeInstance
- compute.instances.use

# Storage services - used when uploading heavy stemcells
- storage.buckets.create
- storage.objects.create
YAML

echo "Creating the BOSH Director role."
PROJECTID="$(gcloud config list --format 'value(core.project)' 2>/dev/null)"
gcloud beta iam roles --project $PROJECTID create bosh.director \
  --file <( bosh int -v project_id=$PROJECTID bosh-director-role.yml )

ACCOUNTNAME="bosh-director-service-account"

echo "Creating a service account using the gcloud CLI."
gcloud iam service-accounts create $ACCOUNTNAME

echo "Creating a key file for your service account."
gcloud iam service-accounts keys create "$ACCOUNTNAME.key.json"  --iam-account "$ACCOUNTNAME@$PROJECTID.iam.gserviceaccount.com"

echo "Binding the service account to your project and give it the owner role"
gcloud projects add-iam-policy-binding $PROJECTID --member 'serviceAccount:'${ACCOUNTNAME}'@'${PROJECTID}'.iam.gserviceaccount.com' --role 'projects/cloud-trai
ning-9/roles/bosh.director'
