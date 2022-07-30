const Contacts = artifacts.require("flipCard.sol");

module.exports = function(deployer) {
  deployer.deploy(Contacts);
};