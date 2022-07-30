const Router = require("express").Router();
const {all_nft} = require("../controllers/nft.controllers");

Router.get("/all",all_nft)

module.exports = Router;