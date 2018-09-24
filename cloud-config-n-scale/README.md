# Update Cloud-Config and Then Scale

## Add external ip to your deployment
First we will ask our IaaS for an IP.
```
gcloud beta compute addresses create router-ip  --region=us-east1 --network-tier=PREMIUM
gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address'
```

### BOSH Cloud config
To update our cloud config we have to look at how our cloud-config was setup. Well bbl setup our cloud-config, and then exposed the files it used. In our `$BBL_STATE_DIRECTORY` which is our setup-bosh-environment directory.

```
cd $BBL_STATE_DIRECTORY
```

[Updating Cloud Config](https://bosh.io/docs/update-cloud-config/)  
The cloud config is a YAML file that defines IaaS specific configuration used by all deployments. It allows to separate IaaS specific configuration into its own file and keep deployment manifests IaaS agnostic.

### Cloud config examples
[AWS CPI example](https://bosh.io/docs/aws-cpi/#cloud-config)  
[Azure CPI example](https://bosh.io/docs/azure-cpi/#cloud-config)  
[OpenStack CPI example](https://bosh.io/docs/openstack-cpi/#cloud-config)  
[SoftLayer CPI example](https://bosh.io/docs/softlayer-cpi/#cloud-config)  
[Google Cloud Platform CPI example](https://bosh.io/docs/google-cpi/#cloud-config)  
[vSphere CPI example](https://bosh.io/docs/vsphere-cpi/#cloud-config)  

If we look at cloud-config directory we see a bare base file that has a skeleton called `cloud-config/cloud-config.yml`, but we see the there is another file called `cloud-config/ops.yml` that used as an operations file.  

### cloud config update, specific vip type to allow us to use external static IP
```file:cloud-config/ops.yml
- type: replace
  path: /networks/-
  value:
    name: public
    type: vip
```

### We are also going to explore adding a custom tag to our vm
```file:cloud-config/ops.yml
- type: replace
  path: /vm_extensions/-
  value:
     name: gcp-tag
     cloud_properties:
       tags: [router-ip-open]
```       

Verify
```
bosh int <(bosh int cloud-config/cloud-config.yml -o cloud-config/ops.yml ) -l vars/cloud-config-vars.yml
```

Apply
```
bosh update-cloud-config <(bosh int cloud-config/cloud-config.yml -o cloud-config/ops.yml ) -l vars/cloud-config-vars.yml
```

### Update the greeter deployment with static external IP and open up firewall rule for it.
We will create an ops file, `greeter-opfile.yml` for adding our changes, that we will then patch onto main release. Looking at examples doesn't hurt [bosh external ip](https://github.com/cloudfoundry/bosh-deployment/blob/master/external-ip-not-recommended.yml).

Change directory to our release directory.
```
cd ~/greeter-release/
```

Create new ops file.
```file:greeter-opfile.yml
- type: replace
  path: /instance_groups/name=router/networks/0/default?
  value: [dns, gateway]

- type: replace
  path: /instance_groups/name=router/networks/-
  value:
    name: public
    static_ips: [((external_ip))]

- type: replace
  path: /instance_groups/name=router/vm_extensions?
  value: [gcp-tag]
```  

You can verify that values were able to be placed into your manifest, but not necessarily are in right location or valid.
```
bosh int greeter.yml -o greeter-opfile.yml -v external_ip=$(gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address')
```  

Run and see if any changes are detected.
```
bosh -d greeter -n  deploy greeter.yml -o greeter-opfile.yml -v external_ip=$(gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address')
```

Add firewall rule by gathering some info from our setup files. Notice we did not use our new tag. If we look at the console and look at router machine and app machine we will notice that network tags are added for job, release, deployment, etc.
```
cd ../s1p-bosh-lab/setup-bosh-environment
gcloud compute firewall-rules create allow-router-http --direction=INGRESS --priority=1000 --network=$(bosh int vars/director-vars-file.yml --path /network) --action=ALLOW --rules=tcp:8080 --source-ranges=0.0.0.0/0 --target-tags=router
```

Now we should be able to use static ip to address the router directly.
```
curl "http://$(gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address'):8080"
```

## Scale your deployment
In your `~/greeter-release/greeter.yml` manifest:

1. Add the `10.0.255.9` IP from the private static pool to `/instance_groups/name=app/networks/name=private/static_ips/-`
1. Increase the number of instances in `/instance_groups/name=app/instances` to 2
1. Append `10.0.255.9:8080` to the `/instance_groups/name=router/jobs/name=router/properties/upstreams/-` array


The best way to do this is to create an opfile. We are leaving the creation of such file as an excesse to the users. Another option s to update the manifest manually.
Note, that when identifying properties path we use the same syntax, as it is used in opfiles, so them can be copied directly.

Deploy once again:

```exec
bosh  -d greeter -n  deploy -o greeter-opfile.yml greeter.yml
```

And if you `curl` the router multiple times, you should see greetings from different upstreams:

```exec
curl "http://$(gcloud beta compute addresses describe router-ip --region us-east1 --format json|jq -r '.address'):8080"
```
