#!/bin/bash
# test.sh script to crack rsa

DIR=$(cd $(dirname $0) && pwd)
OPENSSL=$DIR/openssl
MSIEVE=$DIR/msieve

bits=200
[ $# -eq 0 ] || bits=$1

# generate the private key (p,q)
$OPENSSL genrsa -out private.pem $bits

# generate the public key with private (e,n) 
$OPENSSL rsa -in private.pem -pubout -out public.pem

# extract the modulus n and the exponent e from the public key
$OPENSSL rsa -in public.pem -pubin -text -modulus -out expmod.out
e=`grep Exponent: expmod.out | cut -d" " -f2`
n_hex=`grep -e 'Modulus=' expmod.out | cut -d"=" -f2`
n=`echo "ibase=16;$n_hex"|bc|tr -d '\\\\\n'`
printf "e: $e\nn: $n\n"

# this might take a while
printf "Factoring $n...\n"
rm  -f msieve.log msieve.dat
#./msieve -v $n
$MSIEVE -v $n

p=`grep "factor: " msieve.log |awk '{print $8}'|head -1`
#p=`echo "obase=16;$p"|bc`
q=`grep "factor: " msieve.log |awk '{print $8}'|tail -1`
#q=`echo "obase=16;$q"|bc`
elapsed=`cat msieve.log | awk '/elapsed time/{print $8}'`
printf "p: $p\nq: $q\n"

$OPENSSL genrsa -p $p -q $q -out private_found.pem
if diff private.pem private_found.pem; then
	printf "\nSuccess! $bits-bit key cracked in $elapsed!\n\n"
else
	printf "\nFail :(\n\n"
fi

