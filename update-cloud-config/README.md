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
---
azs:
- name: z1
  cloud_properties: {zone: ((gcp_zone_1))}

vm_types:
- name: db-small
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-medium
  cloud_properties:
    machine_type: n1-standard-2
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-large
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-xlarge
  cloud_properties:
    machine_type: n1-standard-8
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-2xlarge
  cloud_properties:
    machine_type: n1-standard-16
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-4xlarge
  cloud_properties:
    machine_type: n1-standard-32
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-10xlarge
  cloud_properties:
    machine_type: n1-standard-64
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))
- name: db-16xlarge
  cloud_properties:
    machine_type: n1-standard-96
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: credhub
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: metrics
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

# Concourse Web
- name: concourse-web-small
  cloud_properties:
    machine_type: n1-standard-1
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: concourse-web-medium
  cloud_properties:
    machine_type: n1-standard-2
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: concourse-web-large
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: concourse-web-xlarge
  cloud_properties:
    machine_type: n1-standard-8
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: concourse-web-2xlarge
  cloud_properties:
    machine_type: n1-standard-16
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

# Concourse Workers
- name: worker-medium
  cloud_properties:
    machine_type: n1-standard-2
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: worker-large
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: worker-xlarge
  cloud_properties:
    machine_type: n1-standard-8
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: worker-2xlarge
  cloud_properties:
    machine_type: n1-standard-16
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: worker-4xlarge
  cloud_properties:
    machine_type: n1-standard-32
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: worker-10xlarge
  cloud_properties:
    machine_type: n1-standard-64
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: worker-16xlarge
  cloud_properties:
    machine_type: n1-standard-96
    root_disk_size_gb: 200
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

- name: compilation
  cloud_properties:
    machine_type: n1-standard-2
    preemptible: true
    root_disk_size_gb: 10
    root_disk_type: pd-ssd
    labels:
      turbo: ((env_name))

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
  - range:   ((bosh_subnet_range))
    gateway: ((bosh_subnet_gateway))
    dns:     [8.8.8.8, 8.8.4.4]
    static: ((bosh_network_static_ips))
    reserved: ((bosh_network_reserved_ips))
    azs:     ((az_list))
    cloud_properties:
      network_name: ((bootstrap_network_name))
      subnetwork_name: ((bosh_subnet_name))
      ephemeral_external_ip: false
      tags: ((bosh_network_vm_tags))
- name: concourse
  type: manual
  subnets:
  - range:   ((concourse_subnet_range))
    gateway: ((concourse_subnet_gateway))
    dns:     [8.8.8.8, 8.8.4.4]
    static: ((concourse_network_static_ips))
    reserved: ((concourse_network_reserved_ips))
    azs:     ((az_list))
    cloud_properties:
      network_name: ((bootstrap_network_name))
      subnetwork_name: ((concourse_subnet_name))
      ephemeral_external_ip: false
      tags: ((concourse_network_vm_tags))

vm_extensions:
- name: web
  cloud_properties:
    backend_service:
      name: ((web_backend_group))
    target_pool: ((credhub_target_pool))
- name: metrics
  cloud_properties:
    backend_service:
      name: ((metrics_backend_group))

compilation:
  workers: 3
  reuse_compilation_vms: true
  az: z1
  vm_type: compilation
  network: bosh
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
      turbo: ((env_name))
```

### Add network for Nginx server
[Networks](https://bosh.io/docs/google-cpi/#networks)  
***network [String, required]:*** References a valid network name defined in the Networks block. BOSH assigns network properties to compilation VMs according to the type and properties of the specified network.

```
- name: nginx
  type: manual
  subnets:
  - range:  10.0.0.128/26
    gateway: 10.0.0.129
    dns:     [8.8.8.8, 8.8.4.4]
    static: 10.0.0.131-10.0.0.140
    reserved: 10.0.0.129-10.0.0.130
    azs:      [z1]
    cloud_properties:
      network_name: altoros-automation-boostrap
      subnetwork_name: altoros-automation-concourse
      ephemeral_external_ip: true
      tags: altoros-automation-allow-concourse-https,altoros-automation-allow-ssh
```

### Apply Cloud Config to environment on jumpbox

```
bosh update-cloud-config  update-cloud-config.yml
```
