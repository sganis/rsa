# Cracking RSA
# by sganis
#
# Compile my implementation of openssl:
cd openssl-1.0.1c-sganis
./config
make
cp apps/openssl ..
cd ..

# Compile msieve:
cd msieve-1.52
make all
cp msieve ..
cd ..

# and run 
./test.sh 200

# Details in test.sh


