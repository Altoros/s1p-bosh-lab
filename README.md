# BOSH Addon's Exercise
### Change directories into ~/s1p-bosh-lab/bosh-addons/
```
cd ~/s1p-bosh-lab/bosh-addons/
```
### Create a runtime-config file called runtime.yml
```
vi runtime.yml
```
### Paste in the following code snippet to for the bosh add-on
```
---
releases:
- name: "os-conf"
  version: "20.0.0"
  url: "https://bosh.io/d/github.com/cloudfoundry/os-conf-release?v=20.0.0"
  sha1: "a60187f038d45e2886db9df82b72a9ab5fdcc49d"
addons:
  - name: s1puser-configuration
    jobs:
    - name: login_banner
      release: os-conf
      properties:
        login_banner:
          text: |
            *********************************************
                   HELLO, SpringOne Platform 2018
            *********************************************
    - name: user_add
      release: os-conf
      include:
        instance_groups: [app]
      exclude:
        instance_groups: [router]
      properties:
        users:
        - name: s1puser
          public_key: "<s1puser_public_key>"
```
### Update the public key with the in the runtime.yml with key you generated for s1puser
```
public_key: "<s1puser_public_key>"
```
### Update the runtime-config with BOSH
```
bosh -d greeter update-runtime-config runtime.yml
```
### Re-deploy BOSH for changes to take effect
```
bosh -d greeter deploy ~/greeter-release/greeter.yml
```
### Now we will SSH as the s1puser
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
In this exercise we will add a user account, s1puser, to the app vms.
