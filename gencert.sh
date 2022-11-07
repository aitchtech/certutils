#!/bin/sh

show_help_and_exit () {
    echo "Usage:"
    echo "    -t|--type \"caleaf|standalone\" (default: caleaf)"
    echo "    -n|--commonname <Common Name of certificate> (required)"
    echo "    -p|--pass <password for private key> (default: certpass)"
    echo "    -h|--help"
    exit 1
}

certtype='caleaf'
commonname=''
keypass='certpass'

# Load the user defined parameters
while [[ $# > 0 ]]
do
    case "$1" in
        
        -t|--type)
            certtype="$2"
            shift
            ;;

        -n|--commonname)
            commonname="$2"
            shift
            ;;

        -p|--keypass)
            keypass="$2"
            shift
            ;;

        -h|--help|*)
            show_help_and_exit
            ;;
    esac
    shift
done

# Perform validations on inputs

case "$certtype" in
    (caleaf|standalone)
        ;;
    (*) 
        show_help_and_exit
        ;;
esac

if [[ -z $commonname ]]
then
    show_help_and_exit
fi

# Logic

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

if [ $certtype = caleaf ]
then
echo "Generating as CA Leaf"
openssl ca \
    -in $certdirname/cert_req.csr \
    -out $certdirname/certificate.crt \
    -config root.config \
    -days 365
else
echo "Generating as Standalone"
openssl req \
    -x509 \
    -in $certdirname/cert_req.csr \
    -key $certdirname/private.key \
    -out $certdirname/certificate.crt \
    -config $certdirname/cert_req.config \
    -days 365
echo "This is a standalone certificate, not signed by any CA" >> $certdirname/standalone.txt
fi

openssl pkcs12 \
    -export \
    -name $commonname \
    -out $certdirname/certificate.pfx \
    -password "pass:$keypass" \
    -inkey $certdirname/private.key \
    -in root.crt \
    -in $certdirname/certificate.crt