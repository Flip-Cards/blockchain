## FlipCard Solidity Code

This code contains the Solidity implementation of the NFT Warranty cards. Here are the public getters and public mutation functions.

![alt text](https://humit-shareable.s3.us-east-2.amazonaws.com/posters/flipcard.jpeg "Title")

#### Installation
Install Truffle for running and testing blockchain locally

    npm i -g truffle

Install ganache to run local ethereum blockchain. Download the desktop version from [Here](https://trufflesuite.com/ganache/)
Clone this repository locally. Get inside this folder and run

    npm install

#### Running blockchain locally

Start Local ethereum blockchain using Ganache. Simply run the application and click on "QUICKSTART"
!["Can't load image"](https://humit-shareable.s3.us-east-2.amazonaws.com/posters/ganache.png "Ganache")

Get inside the code respository using command line

Run following command

    truffle migrate

and the server will start.

#### Testing Smart Contract Locally (Automation)

Start the ganache server like we did in the "Running blockchain locally" above. 
Get inside the repository using command line and execute.

    truffle test ./test/flipCard_test.js

This will deploy the server and run the tests so you can check that the smart contract is providing all the functionalities.
