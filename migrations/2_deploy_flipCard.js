const Contacts = artifacts.require("flipCard.sol");

module.exports = function(deployer) {
    deployer.deploy(Contacts)

    // Option 2) Console log the address:
    .then(() => console.log(SimpleStorage.address))

    // Option 3) Retrieve the contract instance and get the address from that:
    .then(() => SimpleStorage.deployed())
    .then(_instance => console.log(_instance.address));
};