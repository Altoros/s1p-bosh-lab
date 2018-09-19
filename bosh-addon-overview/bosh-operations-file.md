## BOSH Operations file (ops file)
A YAML file that includes multiple operations to be applied to a different YAML file. Several CLI commands such as create-env and interpolate allow to provide multiple operations files via --ops-file flag. [See details.](https://bosh.io/docs/cli-ops-files/)  
```
    -o bosh-deployment/gcp/cpi.yml \
    -o bosh-deployment/jumpbox-user.yml \
    -o bosh-deployment/misc/ntp.yml \
    -o bosh-deployment/uaa.yml \
    -o bosh-deployment/credhub.yml \
    -o bosh-deployment/misc/dns.yml \
    -o bosh-deployment/external-ip-not-recommended.yml \
```   
