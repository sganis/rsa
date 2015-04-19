#!/bin/sh
# clean script

cd openssl-1.0.1c-sganis
make clena
cd ..
cd msieve-1.52
make clean
cd ..
rm msieve.* private* public* key.pem expmod.out
