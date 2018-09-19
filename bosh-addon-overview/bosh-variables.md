#### Variable (var)  
Variable points to a saved value in some store. Variables are typically used in configuration files (manifests) to decouple sensitive (passwords, certificates) or volatile (bucket name, number of instances) data from more static content (general configuration). Variables are denoted with double parens -- ((namespace/var-name)).
```
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
