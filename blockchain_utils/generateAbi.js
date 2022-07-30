const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('../build/contracts/flipCard.json', 'utf8'));
console.log(JSON.stringify(contract.abi,null,4));
// fs.writeFileSync("result.json",contract.toString())