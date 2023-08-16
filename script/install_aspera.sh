#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

>&2 cat<<EOF

   The link to download IBM Aspera Connect is not permanent. Please visit:

       https://www.ibm.com/aspera/connect/

   and save the link for the Linux tarball (right-click and save the link
   address).

   This script will install Aspera Connect to ${HOME}/.aspera/. To quit, press
   <Ctrl+c>.

EOF

read -e -p "To continue, please enter the URL for the Linux tarball: " url

until [[ ${url} =~ ^https ]];
do
   read -e -p "Please enter a valid URL: " url
done

tarball=$(basename ${url})
script=$(basename ${tarball} .tar.gz).sh

cd /tmp && \
   wget ${url} && \
   tar -xzf ${tarball} && \
   ./${script} && \
   rm /tmp/ibm-aspera*

if [[ $? -gt 0 ]]; then
   >&2 echo Something went wrong with the installation
   exit 1
fi

if [[ ! -d ${HOME}/.ssh ]]; then
   mkdir ${HOME}/.ssh
fi

wget --quiet https://raw.githubusercontent.com/davetang/learning_docker/main/aspera_connect/asperaweb_id_dsa.openssh -O ${HOME}/.ssh/asperaweb_id_dsa.openssh
wget --quiet https://raw.githubusercontent.com/davetang/learning_docker/main/aspera_connect/asperaweb_id_dsa.openssh.pub -O ${HOME}/.ssh/asperaweb_id_dsa.openssh.pub

>&2 cat<<EOF

   Please add:

       ${HOME}/.aspera/connect/bin/

   to your PATH.

EOF
exit 0
