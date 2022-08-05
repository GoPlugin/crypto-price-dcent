# Crypto-Price-Dcent - A Decentralized way to bring external data to your smart contract
## How to Run
## Installation

[Node.js](https://nodejs.org/) v10+ to run.
Install the dependencies and devDependencies and start the server.

```sh
git clone https://github.com/GoPlugin/crypto-price-dcent.git
cd crypto-price-dcent
```
# Install necessary packages for app folder and start backend api
```
cd app
yarn install
yarn start
```
Result should be something like below
```
Compiled successfully!
You can now view client in the browser.
  Local:            http://localhost:3000
  On Your Network:  http://192.168.1.36:3000
Note that the development build is not optimized.
To create a production build, use yarn build.
```
# Install necessary packages for external-adapter folder and start backend api

'''
cd external-adapter
yarn install
yarn start
'''
Result should be something like this
'''
yarn run v1.22.19
$ node server.js
Listening on port 5002!
'''
# Install necessary packages for xrcserver folder and start backend api
'''
cd xrcserver
yarn install
yarn start
'''
Result should be something like this
'''
yarn run v1.22.19
$ node server.js
Listening on port 5001!
'''

## Start Plugin node & EXternal-initiator
- Follow plugin node setup guide https://docs.goplugin.co/plugin-installations/how-to-install-plugin-node/modular-method-deployment-recommended-approach 
- Make sure, your node is pointed to "Apothem" network
- Create a bridge in Plugin UI & point that to 5002, so the plugin & external-initiator can communicate with external-adapter