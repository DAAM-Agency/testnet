// mint_nft.cdc

import DAAM from 0x045a1763c93006ca
import Profile from 0x192440c99cb17282 // only for Testing

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(/*metadata: DAAM.Metadata*/) {
    let minter: &DAAM.Artist
    let address: Address

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&DAAM.Artist>(from: DAAM.adminStoragePath)!
            //?? panic("Could not borrow a reference to the NFT minter")
        self.address = signer.address
    } 


    let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteArtist(artist)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Artist Invited")


        

    execute {   
        let metadata = DAAM.Metadata(
            title:"Title",
            creator: self.address,
            series: [],
            physical: false,
            agency: "agency",
            about: {"text": "about"},
            thumbnail: {"text":"thumbnail"},
            file: {"text":"file"}
        )    
        log("Metadata completed")
        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(metadata: metadata) //  
        log("NFT Minted")
    }
}
