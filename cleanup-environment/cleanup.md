### Cleanup environment

Congratulations! You have gotten to end of this lab. We will ask you to help us do a little clean up.  

```
cp ~/s1p-bosh-lab/cleanup-environment/cleanup.sh /tmp/
nohup /tmp/cleanup.sh
```

As you start this at the moment you can go to google cloud console and remove the router-ip firewall rule manually at this point. We have to do this since it is created outside of terraform. Next update, I will add instructions to add to terraform. 
