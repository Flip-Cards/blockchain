const MNEMONIC = "rare win chase uncle crop video betray indoor work cup banana fluid"
const API_KEY = "https://ropsten.infura.io/v3/d9d6d74ce9cf4bf299fb2e2a21449229"
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC, API_KEY)
      },
      network_id: 3,
      gas: 30000000      //make sure this gas allocation isn't over 4M, which is the max
    }
  },
  compilers: {
    solc: {
      version: "0.8.10",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}