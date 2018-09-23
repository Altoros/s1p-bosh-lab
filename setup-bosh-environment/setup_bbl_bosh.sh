#!/bin/bash
set -e

# update and install apt managed tools
if [ ! -f /.done ]; then
  sudo apt-get update && sudo apt-get install -y \
	  tree netcat-openbsd build-essential zlibc zlib1g-dev \
	  ruby ruby-dev openssl libxslt-dev libxml2-dev \
	  libssl-dev libreadline6 libreadline6-dev libyaml-dev \
	  libsqlite3-dev sqlite3
  sudo touch /.done
fi

# make bin if not there
[ ! -d ~/bin ] && mkdir ~/bin

if [ -z "$(which direnv)" ]; then
  echo
  echo "Installing direnv..."
  wget -O ~/bin/direnv https://github.com/direnv/direnv/releases/download/v2.17.0/direnv.linux-amd64
fi

if [ -z "$(which bbl)" ]; then
  echo
  echo "Installing bbl..."
  wget -O ~/bin/bbl https://github.com/cloudfoundry/bosh-bootloader/releases/download/v6.10.3/bbl-v6.10.3_linux_x86-64
fi

if [ -z "$(which terraform)" ]; then
  echo
  echo "Installing terraform..."
  TERRAFORMVERSION="0.11.8"
  curl -OL https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORMVERSION}_linux_amd64.zip && rm *.zip
  mv terraform  ~/bin/terraform
fi

if [ -z "$(which bosh)" ]; then
  echo "Installing bosh CLI..." >&2
  curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | wget -qi - -O bosh
  mv bosh ~/bin/bosh
fi

# in .bashrc
grep -q '~/bin:' ~/.bashrc || echo -e 'export PATH=~/bin:$PATH' >> ~/.bashrc
grep -q direnv ~/.bashrc || echo -e 'if [ ! -z "$(which direnv)" ]; then\n  eval "$(direnv hook bash)"\nfi' >> ~/.bashrc

# make exec
chmod +x ~/bin/*

GCP_PROJECT=$DEVSHELL_PROJECT_ID

# Initial setup
# Name to use for GCP service account specific to this environment.
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-s1pbosh}

set +e
  ## Check for account existance
  gcloud iam service-accounts list --format json|jq -r '.[]|.email'|grep "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com"
  if [ $? != 0 ]; then
    echo
    echo "Creating GCP service account..."
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name "Altoros Automation"
    gcloud projects add-iam-policy-binding "$GCP_PROJECT" --member "serviceAccount:$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com" --role "roles/editor"
    gcloud iam service-accounts keys create "$SERVICE_ACCOUNT_NAME.key.json" --iam-account "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com"
  else
    grep "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com" "$SERVICE_ACCOUNT_NAME.key.json"
    if [ $? != 0 ]; then
      # if service account name changed
      gcloud iam service-accounts keys create "$SERVICE_ACCOUNT_NAME.key.json" --iam-account "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com"
      echo "Not recreating account, but added new keys"
    else
      echo "Account already created, not creating or adding more keys to account"
    fi
  fi
set -e

## Prompt user to kick off login Shell
echo -e "Now that all pre-work is done, we will need to do a few more things:\n\nbash -l\ndirenv allow\nbbl up"
