#### Deployment State
bosh create-env command needs to remember resources it creates in the IaaS so that it can re-use or delete them at a later time. The deploy command stores current state of your deployment in a given state file (via --state flag) or implicitly in <manifest>-state.json file in the same directory as your deployment manifest.

This allows you to deploy multiple deployments with different manifests.

Do not delete state file unless you have already deleted your deployment (with bosh delete-env <manifest> or by manually removing the VM, disk(s), & stemcell from the IaaS). We recommend placing the deployment state file and the deployment manifest under version control and saving changes any time after running the deploy or delete commands.
```
    --state=state.json \
```
```
$ cat state.json
{
    "director_id": "1699597b-a6c2-4f83-7b9e-f070f9a763be",
    "installation_id": "b0a34894-1fe6-47e1-74fe-5e04c368e878",
    "current_vm_cid": "vm-6483b4b9-1ce6-46c9-6828-54152a5ab6aa",
    "current_stemcell_id": "c755adb3-15d9-4a76-7c83-01dd1a77072e",
    "current_disk_id": "500d1c1b-c65c-415d-720b-5986033a05b7",
    "current_release_ids": [
        "b2c2e015-45ae-4d01-7eb7-d93fc7ca84ce",
        "e6bbd5fe-6e6c-4cae-78ed-2c21bd109853",
        "1ef64545-d8b6-415c-63ba-efa1f5a1f5c0",
        "54f49939-5280-4c07-5616-e0f738750a24",
        "a2e11bbd-f55c-49b1-6289-084ceb035e3d",
        "3c88fb8e-c0ad-4fee-655c-fbf0e5f425dc"
    ],
    "current_manifest_sha": "25c1cdefa9f61616d6e445790a40b2704f55534034cb4c258791a5800f65c6f73ca071ec4e2da4bbd421c2af5d1445bf74cd39aa30687fa32f0a57482eadf06e",
    "disks": [
        {
            "id": "500d1c1b-c65c-415d-720b-5986033a05b7",
            "cid": "disk-af3f8967-5ea1-49b0-7207-b5c8e7b550b7",
            "size": 65536,
            "cloud_properties": {
                "type": "pd-standard"
            }
        }
    ],
    "stemcells": [
        {
            "id": "c755adb3-15d9-4a76-7c83-01dd1a77072e",
            "name": "bosh-google-kvm-ubuntu-xenial-go_agent",
            "version": "97.12",
            "cid": "stemcell-db386ec5-0248-4371-620f-8b8d6c397098"
        }
    ],
    "releases": [
        {
            "id": "b2c2e015-45ae-4d01-7eb7-d93fc7ca84ce",
            "name": "bosh",
            "version": "268.0.1"
        },
        {
            "id": "e6bbd5fe-6e6c-4cae-78ed-2c21bd109853",
            "name": "bpm",
            "version": "0.11.0"
        },
        {
            "id": "1ef64545-d8b6-415c-63ba-efa1f5a1f5c0",
            "name": "bosh-google-cpi",
            "version": "27.0.1"
        },
        {
            "id": "54f49939-5280-4c07-5616-e0f738750a24",
            "name": "os-conf",
            "version": "18"
        },
        {
            "id": "a2e11bbd-f55c-49b1-6289-084ceb035e3d",
            "name": "uaa",
            "version": "60.2"
        },
        {
            "id": "3c88fb8e-c0ad-4fee-655c-fbf0e5f425dc",
            "name": "credhub",
            "version": "2.0.2"
        }
    ]
```
