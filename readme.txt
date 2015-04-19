# Cracking RSA
# by Ganix (crypto@gmail.com)
#
# Executables are compiled for Mac (10.6).
# Compile my implementation of openssl:
cd openssl-ganix-1...
./config
make
cp apps/openssl ../openssl-ganix
cd ..

# Compile msieve:
cd msieve-1...
make
cp msieve ..
cd ..
 
# and run 
./test.sh [key-length]

# Details in test.sh


