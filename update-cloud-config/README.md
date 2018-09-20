# BOSH Cloud config
[Updating Cloud Config](https://bosh.io/docs/update-cloud-config/)  
The cloud config is a YAML file that defines IaaS specific configuration used by all deployments. It allows to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic.

### Cloud config examples
[AWS CPI example](https://bosh.io/docs/aws-cpi/#cloud-config)  
[Azure CPI example](https://bosh.io/docs/azure-cpi/#cloud-config)  
[OpenStack CPI example](https://bosh.io/docs/openstack-cpi/#cloud-config)  
[SoftLayer CPI example](https://bosh.io/docs/softlayer-cpi/#cloud-config)  
[Google Cloud Platform CPI example](https://bosh.io/docs/google-cpi/#cloud-config)  
[vSphere CPI example](https://bosh.io/docs/vsphere-cpi/#cloud-config)  

### GCP Cloud config example <-> Work in progress
```
PROJECTENV="CHANGEME"
cat > update-cloud-config.yml << YAML
---
azs:
- name: z1
  cloud_properties: {zone: us-east1-b}

vm_types:
- name: db-small
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-medium
  cloud_properties:
    machine_type: n1-standard-2
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-large
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-xlarge
  cloud_properties:
    machine_type: n1-standard-8
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-2xlarge
  cloud_properties:
    machine_type: n1-standard-16
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-4xlarge
  cloud_properties:
    machine_type: n1-standard-32
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-10xlarge
  cloud_properties:
    machine_type: n1-standard-64
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV
- name: db-16xlarge
  cloud_properties:
    machine_type: n1-standard-96
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: credhub
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: metrics
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo:  -concourse-https-lb-backend-1az

# Concourse Web
- name: concourse-web-small
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: concourse-web-medium
  cloud_properties:
    machine_type: n1-standard-2
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: concourse-web-large
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: concourse-web-xlarge
  cloud_properties:
    machine_type: n1-standard-8
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: concourse-web-2xlarge
  cloud_properties:
    machine_type: n1-standard-16
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

# Concourse Workers
- name: worker-medium
  cloud_properties:
    machine_type: n1-standard-2
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: worker-large
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: worker-xlarge
  cloud_properties:
    machine_type: n1-standard-8
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: worker-2xlarge
  cloud_properties:
    machine_type: n1-standard-16
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: worker-4xlarge
  cloud_properties:
    machine_type: n1-standard-32
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: worker-10xlarge
  cloud_properties:
    machine_type: n1-standard-64
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: worker-16xlarge
  cloud_properties:
    machine_type: n1-standard-96
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

- name: compilation
  cloud_properties:
    machine_type: n1-standard-2
    preemptible: true
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: $PROJECTENV

disk_types:
- name: 10G
  disk_size: 10240
- name: 25G
  disk_size: 25600
- name: 50G
  disk_size: 51200
- name: 100G
  disk_size: 102400
- name: 250G
  disk_size: 256000
- name: 500G
  disk_size: 512000
- name: 1000G
  disk_size: 1024000

networks:
- name: bosh
  type: manual
  subnets:
  - range:   10.0.0.64/26
    gateway: 10.0.0.65
    dns:     [8.8.8.8, 8.8.4.4]
    static: 10.0.0.71-10.0.0.74
    reserved: 10.0.0.64-10.0.0.70
    azs:     [z1]
    cloud_properties:
      network_name: $PROJECTENV-boostrap
      subnetwork_name: $PROJECTENV-bosh
      ephemeral_external_ip: false
      tags: [$PROJECTENV-internal,$PROJECTENV-nat]
- name: concourse
  type: manual
  subnets:
  - range:   10.0.0.128/26
    gateway: 10.0.0.129
    dns:     [8.8.8.8, 8.8.4.4]
    static: 10.0.0.133-10.0.0.136
    reserved: 10.0.0.128-10.0.0.132
    azs:     [z1]
    cloud_properties:
      network_name: $PROJECTENV-boostrap
      subnetwork_name:  $PROJECTENV-concourse
      ephemeral_external_ip: false
      tags: [$PROJECTENV-internal,$PROJECTENV-nat]

vm_extensions:
- name: web
  cloud_properties:
    backend_service:
      name: $PROJECTENV-concourse-https-lb-backend-1az
    target_pool: $PROJECTENV-credhub
- name: metrics
  cloud_properties:
    backend_service:
      name: $PROJECTENV-metrics-https-lb-backend-1az

compilation:
  workers: 3
  reuse_compilation_vms: true
  az: z1
  vm_type: compilation
  network: bosh
YAML
```



### Edit the cloud-config settings above using the information below
```
vim update-cloud-config.yml
```

### Add VM Type for Nginx server under the vm_types section
[VM Types / VM Extension](https://bosh.io/docs/google-cpi/#vm-types)
```
- name: nginx-small
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: CHANGE_TO_PROJECTENV
```

### Add network for Nginx server
[Networks](https://bosh.io/docs/google-cpi/#networks)  
***network [String, required]:*** References a valid network name defined in the Networks block. BOSH assigns network properties to compilation VMs according to the type and properties of the specified network.

```

- name: nginx
  type: manual
  subnets:
  - range:   10.0.0.128/26
    gateway: 10.0.0.129
    dns:     [8.8.8.8, 8.8.4.4]
    static: 10.0.0.133-10.0.0.136
    reserved: 10.0.0.128-10.0.0.132
    azs: [z1]
    cloud_properties:
      network_name: CHANGE_TO_PROJECTENV-boostrap
      subnetwork_name:  CHANGE_TO_PROJECTENV-concourse
      ephemeral_external_ip: true
      tags: [CHANGE_TO_PROJECTENV-internal,CHANGE_TO_PROJECTENV-nat]
```

### Apply Cloud Config to environment on jumpbox

```
bosh update-cloud-config  update-cloud-config.yml
```
