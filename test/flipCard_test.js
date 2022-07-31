
const nftContract = artifacts.require("flipCard");

contract(nftContract, (accounts) => {
  it("should check if the blockchain is live and accessible", async () => {
    let instance = await nftContract.deployed();
    const balance = await instance.heartbeat.call();
    assert.equal(balance.toNumber(), 1, "The blockchain isn't initialized or connected correctly");
  })

  it("should mint a new nft", async () => {
    let instance = await nftContract.deployed()
    let initial = await instance.tokenSupply();
    initial = initial.toNumber();
    let newNFT = await instance.safeMint(instance.address, "ipfs://warranty_card_1", "SIN36519ec325a9807b28e971e1e26fa9cfd88813feab2405e65f9a90e47dc1f6a1");
    let later = await instance.tokenSupply();
    later = later.toNumber();

    assert.equal(initial + 1, later, "One new NFT should be added")

  })

  it("should mint batch of nfts", async () => {
    let instance = await nftContract.deployed();
    let data = ["ipfs://warranty_card_2", "ipfs://warranty_card_3"];
    let serials = ["SIN328eeef66d8d660e78367741cd9da51df12a486f624de1f4798e7e7b68fd34f7", "SIN81bb4896a84897c8fe45462e86690aadaa9ce6de0b2126d79de83086f5bb30d7"];
    let newNfts = await instance.safeMintBatch(instance.address, data, serials);
    let totalNfts = (await instance.tokenSupply()).toNumber();

    //3 because 2 NFT are minted right now and one before this testcase
    assert.equal(totalNfts, 3, "Total NFTs should be equal to 2")
  })

  it("should return the tokenId for the given serial number", async () => {
    let instance = await nftContract.deployed();
    let serialNumber = "SIN328eeef66d8d660e78367741cd9da51df12a486f624de1f4798e7e7b68fd34f7";
    let tokenId = (await instance.getURIToken(serialNumber)).toNumber();

    assert.equal(tokenId, 1, "token id should be 1")

  })

  it("should return the tokenURI for a given tokenId", async () => {
    let instance = await nftContract.deployed();
    let uri = (await instance.tokenURI(1));
    assert.equal(uri, "ipfs://warranty_card_2", "tokenURI should be ipfs://warranty_card_2")
  })

  it("should update the tokenURI for the given serial number", async () => {
    let instance = await nftContract.deployed();
    let serialNumber = "SIN81bb4896a84897c8fe45462e86690aadaa9ce6de0b2126d79de83086f5bb30d7";
    let tokenId = (await instance.getURIToken(serialNumber)).toNumber();
    let newUri = "ipfs://wallet_updated_address";

    let res = await instance.updateTokenUri(tokenId, newUri);
    let uri = (await instance.tokenURI(tokenId));

    assert.equal(uri, newUri, `After updating the new uri should be ${newUri}`)
  })

  it("should update the tokenURI for the given token", async () => {
    let instance = await nftContract.deployed();
    let tokenId = 1;
    let newUri = "ipfs://wallet_updated_address";

    let res = await instance.updateTokenUri(tokenId, newUri);
    let uri = (await instance.tokenURI(tokenId));

    assert.equal(uri, newUri, `After updating the new uri should be ${newUri}`)

  })

  it("should tranfer the NFT to user", async () => {
    let instance = await nftContract.deployed();

    ///creating a new minter for the company /brand
    const new_company_minter = accounts[0];
    await instance.addRole(new_company_minter, "MINTER_ROLE")
    
    //minting a new NFT this NFT will be minted and sent to the address of the minter i.e new_company_minter
    await instance.safeMint(new_company_minter, "ipfs://warranty_card_4", "SIN5e2e5221207b6f2bbd037ad5d35fd0530b9dddbc255572b067a7291dac1b3a0c");
    
    //getting token ID for the newly minted serial number
    let newTokenId = (await instance.getURIToken("SIN5e2e5221207b6f2bbd037ad5d35fd0530b9dddbc255572b067a7291dac1b3a0c")).toNumber()
    
    //validating that Warranty card belongs to the minter right now
    let newOwnerOfToken = await instance.ownerOf(newTokenId);
    assert.equal(newOwnerOfToken,new_company_minter,"the owner of nft warranty card should be the minter");

    //customer whom to transfer the NFT
    let customer = accounts[1];
    ///tranfering the ownership to the customer
    (await instance.safeTransferFrom(new_company_minter, customer, newTokenId))

    // checking if the NFT is now owned by the customer
    newOwnerOfToken = await instance.ownerOf(newTokenId);
    assert.equal(newOwnerOfToken,customer,"new nft owner should be the customer")
  })

  it("should file a repair request from the customer side",async ()=>{
    let instance = await nftContract.deployed();

    //Owner of NFT / customer
    let customer = accounts[1];
    let tokenId = (await instance.getURIToken("SIN5e2e5221207b6f2bbd037ad5d35fd0530b9dddbc255572b067a7291dac1b3a0c")).toNumber()
    
    //sending a nft update request
    await instance.updateUserWarranty(tokenId,{from:customer});

    let status = await instance.getUserWarrantyStatus(tokenId);
  })

  it("should complete the warranty repair request from the company side",async ()=>{
    let instance = await nftContract.deployed();

    //Owner of NFT / customer
    let customer = accounts[1];
    let tokenId = (await instance.getURIToken("SIN5e2e5221207b6f2bbd037ad5d35fd0530b9dddbc255572b067a7291dac1b3a0c")).toNumber()
    
    let company_book_keeper = accounts[0];
    await instance.addRole(company_book_keeper,"BOOK_KEEPER_ROLE");

    await instance.updateCompanyWarranty(tokenId);
  })

  it("should confirm a repairment is done through the warranty card",async ()=>{
    let instance = await nftContract.deployed();

    //getting the tokenId
    let tokenId = (await instance.getURIToken("SIN5e2e5221207b6f2bbd037ad5d35fd0530b9dddbc255572b067a7291dac1b3a0c")).toNumber()
    let repairs_on_nft = await instance.getRepairs(tokenId);

    //checking if one new repair is inserted in the warranty nft carf
    assert.equal(repairs_on_nft.length,1,"total repairs on this nft should be 1")
  })



})