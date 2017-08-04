#!/bin/bash
set -x # Show the output of the following commands (useful for debugging)
    
# Import the SSH deployment key
- openssl aes-256-cbc -K $encrypted_0915310d3ea2_key -iv $encrypted_0915310d3ea2_iv -in lbpm-deploy.enc -out lbpm-deploy -d
rm lbpm-deploy.enc # Don't need it anymore
chmod 600 lbpm-deploy
mv lbpm-deploy ~/.ssh/id_rsa
    
# Install zopfli
git clone https://code.google.com/p/zopfli/
cd zopfli
make
chmod +x zopfli
cd ..