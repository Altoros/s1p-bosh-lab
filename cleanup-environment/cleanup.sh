!#/bin/bash

pushd $BBL_STATE_DIRECTORY
  bosh delete-deployment -d greeter -n
  bbl destroy -n
popd

cd ~/

rm -rf bin  greeter-release   packages  s1p-bosh-lab
rm -rf .bash_logout  .config  .terraform.d  .ssh  .bosh  .bash_history
