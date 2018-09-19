# BOSH Addon's Exercises

## What is BOSH
BOSH is a project that unifies release engineering, deployment, and lifecycle management of small and large-scale cloud software. BOSH can provision and deploy software over hundreds of VMs. It also performs monitoring, failure recovery, and software updates with zero-to-minimal downtime.  
[More about BOSH](https://bosh.io/docs/)

## What problems does BOSH solve?
BOSH allows individual developers and teams to easily version, package and deploy software in a reproducible manner.  
[Project Goals](https://bosh.io/docs/problems/)

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

## Exercises
1. [Setup BOSH environment](https://github.com/tosin2013/altoros_bosh_training/tree/master/setup-bosh-environment)
2. [Login to BOSH Director](https://github.com/tosin2013/altoros_bosh_training/tree/master/login-to-bosh-director)
3. [Update BOSH Cloud Config](https://github.com/tosin2013/altoros_bosh_training/tree/master/bosh-cloud-config)
4. [BOSH ADDON overview](https://github.com/tosin2013/altoros_bosh_training/tree/master/bosh-addon-overview)
5. [jumpbox-boshrelease](https://github.com/tosin2013/altoros_bosh_training/tree/master/jumpbox-boshrelease)
6. [nginx-release](https://github.com/tosin2013/altoros_bosh_training/tree/master/nginx-release)
7. [logsearch-boshrelease](https://github.com/tosin2013/altoros_bosh_training/tree/master/logsearch-boshrelease)