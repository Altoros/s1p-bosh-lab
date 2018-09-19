# Log in to BOSH Director

### Configure local alias
```
cd ~/bosh-1
DIRECTOR_IP="YOUR_DIRECTOR_IP"
bosh alias-env bosh-1 -e $DIRECTOR_IP --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)
```
### Log in to the Director
```
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`
bosh -e bosh-1 log-in
```

### Query the Director for more info
```
bosh -e bosh-1 env
```
