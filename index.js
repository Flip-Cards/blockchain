const express = require("express");
const server = express();
const cors = require("cors");
const Web3 = require("web3");
const contract = require("@truffle/contract");
const artifacts = require("./build/contracts/flipCard.json");
const CONTACT_ABI = require("./config");
const CONTACT_ADDRESS = require("./config");
const routes = require("./routes");

server.use(cors());
server.use(express.json());
server.use(express.urlencoded({ extended: false }));

const PORT = process.env.PORT || 8000;

if (typeof web3 !== "undefined") {
  var web3 = new Web3(web3.currentProvider);
} else {
  var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
}

server.listen(PORT, async () => {
  const accounts = await web3.eth.getAccounts();
  const flipCard = new web3.eth.Contract(
    CONTACT_ABI.CONTACT_ABI,
    CONTACT_ADDRESS.CONTACT_ADDRESS
  );

  // const LMS = contract(CONTACT_ABI.CONTACT_ABI)
  // LMS.setProvider(web3.currentProvider);
  // console.log(LMS)
  // const lms = await LMS.deployed();
  server.set("accounts", accounts);
  server.set("flipcard", flipCard);
  console.log(accounts)
  routes(server,accounts,flipCard)
});

exports.server = server;
