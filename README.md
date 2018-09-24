## What is BOSH
BOSH is a project that unifies release engineering, deployment, and lifecycle management of small and large-scale cloud software. BOSH can provision and deploy software over hundreds of VMs. It also performs monitoring, failure recovery, and software updates with zero-to-minimal downtime.  	cd ~/s1p-bosh-lab/bosh-addons/
[More about BOSH](https://bosh.io/docs/)	
 ### Create a runtime-config file called runtime.yml
## What problems does BOSH solve?
BOSH allows individual developers and teams to easily version, package and deploy software in a reproducible manner.  	vi runtime.yml
[Project Goals](https://bosh.io/docs/problems/)
 ### Paste in the following code snippet to for the bosh add-on
## Exercises	
1. [Setup BOSH environment](setup-bosh-environment)
1. [Create Greeter Bosh Release](create-bosh-release)	releases:
1. [Cloud Config & Scale](cloud-config-n-scale)	- name: "os-conf"
1. [Deployment troubleshooting using BOSH](bosh-troubleshooting)	  version: "20.0.0"
   url: "https://bosh.io/d/github.com/cloudfoundry/os-conf-release?v=20.0.0"
## Extra	  sha1: "a60187f038d45e2886db9df82b72a9ab5fdcc49d"
1. [Bosh Addons](bosh-addons)	addons:
1. [Creating a Nginx BOSH release](nginx-release)	  - name: s1puser-configuration
     jobs:
## Clean up	    - name: login_banner
1. [Clean up](cleanup-environment)
