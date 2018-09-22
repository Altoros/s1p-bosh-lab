#!/bin/bash

# Ubuntu trusty
bosh_cmd=$(curl -s https://bosh.io/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent|grep -A2 "bosh upload-stemcell"|sed -e 's/<div.*<pre>//g' -e 's/<a.*">//g' -e 's/<\/a>.*$//g' -e 's/\\//g' |tr -d '\n')
eval $bosh_cmd

# Ubuntu Xenial
bosh_cmd=$(curl -s https://bosh.io/stemcells/bosh-google-kvm-ubuntu-xenial-go_agent|grep -A2 "bosh upload-stemcell"|sed -e 's/<div.*<pre>//g' -e 's/<a.*">//g' -e 's/<\/a>.*$//g' -e 's/\\//g' |tr -d '\n')

eval $bosh_cmd
