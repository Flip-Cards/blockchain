function routes(server,accounts,flipCard){
    server.get("/all",async (req,res,next)=>{
        console.log(flipCard.methods);
        let data = await flipCard.methods.heartbear().call();
        res.send({message:"worked"})
    })
}

module.exports = routes