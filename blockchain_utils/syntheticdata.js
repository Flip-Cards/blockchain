/**Generate random syntehtic warranty cards */
const crypto = require("crypto");

function syntheticData(rows){

    let data = [];
    for(let i=0;i<10;i++){
        let sid = "SIN"+crypto.randomBytes(32).toString("hex")
        let temp = {
            name:  `Warranty card ${i}`,
            description:`Warranty card by apple`,
            image:"https://images.news18.com/ibnlive/uploads/2019/08/flipkart.jpg",
            issuedOn:"",
            issuedTo:"",
            serial:sid
        }
        data.push(temp)
    }
    console.log(data)

}
syntheticData()

