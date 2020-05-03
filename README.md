# zowe-cli-scripts

## renew-cert.sh

This script runs on a RHEL8 system to automatically trigger renewal of Let's Encrypt certificate for zos.duckdns.org and drive the zowe-cli command to install the new certificate on the z/OS system in the RACF KEYRING, it also automatically refresh the zOS Connect Server keystore to pick up the certificate.

## others
