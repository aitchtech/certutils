#!/bin/sh

# 
# https://superuser.com/a/1590560
#

commonname=$1
keypass=$2

if [[ -z $commonname ]]
then
    echo "Common Name must be supplied as first parameter"
    exit 1
fi

if [[ -z $keypass ]]
then
    keypass="certpass"
fi

hostname=$(hostname)
ips=`powershell -Command 'Get-NetIPAddress -AddressFamily IPv4 |  %{ "IP.{0} = {1}" -f ++$IPInd, $_.IPAddress }'`

basedir=~/certs
certdirname=${commonname// /_}
targetdir=$basedir/$certdirname

mkdir -p $targetdir
cd $basedir

echo "[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = PK
stateOrProvinceName = N/A
localityName = N/A
organizationName = $hostname
commonName = $commonname

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $hostname
DNS.2 = localhost
$ips
" > $certdirname/cert_req.config

openssl genrsa \
    -passout "pass:$certpass" \
    -out $certdirname/private.key \
    2048

openssl req \
    -new \
    -key $certdirname/private.key \
    -passin "pass:$certpass" \
    -out $certdirname/cert_req.csr \
    -config $certdirname/cert_req.config

echo "$keypass" >> $certdirname/keypass.txt