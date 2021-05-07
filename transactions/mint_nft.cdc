import DAAM from 0x045a1763c93006ca

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(/*metadata: DAAM.Metadata*/) {
    let minter: &DAAM.Admin

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    } 

    execute {   
        let metadata = DAAM.Metadata(
        title  : "Title", 
        file   : {"text":"file"},
        creator: self.address,  //&Profile
        about  : {"text":"about"},
        physical: false,
        series : [],
        agency : "Agency",
        thumbnail: {"text":"thumbnail"}
        )     
        log("Metadata completed")

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(metadata: metadata) //  
        log("NFT Minted")
    }
}
