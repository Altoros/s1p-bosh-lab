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

### GCP Cloud config example
```
IPADDRESSOCTECT=$(hostname -i  | cut -d"." -f1-3)
cat > cloud-config.yml << YAML
azs:
- name: z1
  cloud_properties: {zone: us-east1-b}
- name: z2
  cloud_properties: {zone: us-east1-c}
- name: z3
  cloud_properties: {zone: us-east1-d}

vm_types:
- name: default
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 20
    root_disk_type: pd-ssd

disk_types:
- name: default
  disk_size: 3000

networks:
- name: default
  type: manual
  subnets:
  - range:   $IPADDRESSOCTECT.0/24
    gateway: $IPADDRESSOCTECT.1
    dns:     [8.8.8.8, 8.8.4.4]
    azs:     [z1, z2, z3]
    cloud_properties:
      network_name: default
      ephemeral_external_ip: true
      tags: [internal]
- name: vip
  type: vip

compilation:
  workers: 3
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: default
YAML
```

### Apply Cloud Config to environment

```
bosh -e bosh-1 update-cloud-config cloud-config.yml
```
