#!/bin/bash
##
# zowe profiles create zosmf zPDT --host s0w1.duckdns.org --port 10443 --user IBMUSER --password XXXX --reject-unauthorized false
##
set -e
sudo systemctl stop haproxy
# 1. Renew Let's Encrypt Certificate
sudo certbot renew
sudo systemctl start haproxy
# 2. Package certificate & private key into p12 format
mkdir -p ~/cert-renew.tmp && cd ~/cert-renew.tmp
sudo openssl pkcs12 -export -in /etc/letsencrypt/live/s0w1.duckdns.org/fullchain.pem \
    -inkey /etc/letsencrypt/live/s0w1.duckdns.org/privkey.pem -name s0w1.duckdns.org -out s0w1.duckdns.org.p12 \
    -passout pass:CERTPWD
sudo chmod 664 s0w1.duckdns.org.p12
# 3. Upload to z/OS dataset
zowe zos-files create data-set-sequential 'IBMUSER.S0W1.DUCKDNS.ORG.P12.ZOWE' \
    --block-size 6233 --primary-space 1 --secondary-space 1 \
    --record-format VB --record-length 256 --size 1TRK --show-attributes true
zowe zos-files upload file-to-data-set s0w1.duckdns.org.p12 'IBMUSER.S0W1.DUCKDNS.ORG.P12.ZOWE' --binary
# 4. Submit JCL to import to RACF database & connect to zOS Connect RING
jobid=$(zowe zos-jobs submit stdin --wfo --rff jobid --rft string <<EOF
//UPDCERT JOB ,CLASS=A,REGION=0M
//RACFCMD EXEC PGM=IKJEFT01
//SYSTSPRT DD SYSOUT=*
//SYSTSIN DD *
RACDCERT REMOVE(SITE LABEL('SERVERCERT') RING(ZCONNECT)) +
         ID(ZOSCSRV)
RACDCERT REMOVE(SITE LABEL('SERVERCERT') RING(IZUKeyring.IZUDFLT)) +
         ID(IZUSVR)
RACDCERT SITE DELETE(LABEL('SERVERCERT'))
RACDCERT SITE ADD('IBMUSER.S0W1.DUCKDNS.ORG.P12.ZOWE') TRUST + 
         WITHLABEL('SERVERCERT') PASSWORD('CERTPWD')
RACDCERT CONNECT(SITE LABEL('SERVERCERT') RING(ZCONNECT) +
         USAGE(PERSONAL) DEFAULT) ID(ZOSCSRV)
RACDCERT CONNECT(SITE LABEL('SERVERCERT') RING(IZUKeyring.IZUDFLT) +
         USAGE(PERSONAL) DEFAULT) ID(IZUSVR) 
SETROPTS RACLIST(DIGTCERT, DIGTRING) REFRESH
/*
EOF
)
zowe zos-jobs view job-status-by-jobid "$jobid"
# 5. Refresh z/OS Connect EE server keystore to pick up new certificate
zowe console issue command "MODIFY ZOSCSRV,REFRESH,KEYSTORE" -w 10
# 6. Clean-up
zowe zos-files delete data-set 'IBMUSER.S0W1.DUCKDNS.ORG.P12.ZOWE' -f
rm -rf ~/cert-renew.tmp
# FINISH
