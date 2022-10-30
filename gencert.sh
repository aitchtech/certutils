#!/bin/sh

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

basedir=~/certs
certdirname=${commonname// /_}
targetdir=$basedir/$certdirname

scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

mkdir -p $targetdir
cd $basedir

if [ ! -f $certdirname/cert_req.csr ]
then
    $scriptdir/gencsr.sh $commonname $keypass
fi

openssl ca \
    -in $certdirname/cert_req.csr \
    -out $certdirname/certificate.crt \
    -config root.config \
    -days 365

openssl pkcs12 \
    -export \
    -name $commonname \
    -out $certdirname/certificate.pfx \
    -password "pass:$keypass" \
    -inkey $certdirname/private.key \
    -in root.crt \
    -in $certdirname/certificate.crt