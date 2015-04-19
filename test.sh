#!/bin/bash
#
# Cracking RSA
# Author: 	Ganix (crypto@gmail.com)
# Date:   	30/11/2006
# Update: 	31/10/2012, using latest msieve 1.50, tested in Mac 1.6
#			28/03/2014, using mpi with msive 1.52, tested in Ubuntu 12.10
#
# RSA Concepts
#
# Key generation:
# - generate 2 random prime numbers (p,q)
#	- n=pq is the modulus
# - relative prime count is f(n) = (p-1)(q-1)
# - e is chosen such that 1<e<f(n) and gcd(f(n),e)=1
# 	in openssl-ganix is fixed: 2^16=65537
# - d = e^-1 mod f(n)
# - (e,n) is the public key, usually stored in a file in PEM format
# - (d,p,q) is the private key, same format, but usually encrypted
#
# Encryption:
# - M is the message in clear text, then C=M^e mod n
#
# Decryption:
# - M = C^d mod n
#		the proof is not here, but M=(M^e)^d mod n
#
# Breaking RSA:
# Well, we have the public key (e,n) and we need to find the private key (d,p,q). 
# d = e^-1 mod (p-1)(q-1), so the unkown data is p and q. We have n=pq.
# Solution: we must factorize n. It seems very easy...
# Problem 1: n is really big, 1024 bit number is about 300 digits.
# Problem 2: even worse, n has only 2 factors, p and q, also big prime numbers.
#
# Usage:
# run ./test.sh [key-length]
#
# To get an idea of time:
# $ for (( i=32; i<=256; i+=8 ));do ./test.sh $i;done 2>&1| grep Success
#
# How it works:
# - First, generates a private key using openssl. Any tool can be used.
#   The reason I am using my own implementation is because openssl does not provide
#   an option to create a private key with 2 given prime numbers.
# - Then, generates the public key using the private key.
# - After that, get the public key components: modulus n and exponent e. With only 
#   this information, we are supposed to get the private key :)
# - Use msieve to factorize n, a big number, http://sourceforge.net/projects/msieve
#   Msive is an implementation of the fastest factorization algorithm known today, GNFS.
#   If successful, we have p and q.
# - Use my openssl implementation to create a private key with p and q
# - Finally, compares the found key with the original to verify success 

DIR=$(cd $(dirname $0) && pwd)
OPENSSL=$DIR/openssl-ganix
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

