# BOSH Addon's Exercise

## What are BOSH Addon's?
An addon is a release job that is colocated on all VMs managed by the Director.
```
addons [Array, optional]: Specifies the addons to be applied to all deployments.

name [String, required]: A unique name used to identify and reference the addon.  
jobs [Array of hashes, requires]: Specifies the name and release of release jobs to be colocated.  
name [String, required]: The job name.  
release [String, required]: The release where the job exists.  
properties [Hash, optional]: Specifies job properties. Properties allow the Director to configure jobs to a specific environment.  
include [Hash, optional]: Specifies inclusion placement rules Available in bosh-release v260+.  
exclude [Hash, optional]: Specifies exclusion placement rules. Available in bosh-release v260+.  
```
[Director Runtime Config](https://bosh.io/docs/runtime-config/#addons)  
[Common Addons](https://bosh.io/docs/addons-common/)
