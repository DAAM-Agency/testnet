// submit_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(/*metadata: DAAM.Metadata */) {
    // local variable for storing the creator reference
    let creatorRef    : &DAAM.Creator
    let creatorAddress: Address
    
    prepare(creator: AuthAccount) {
        // borrow a reference to the Creator resource in storage
        self.creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)
            ?? panic("Could not borrow a reference to the NFT creator")
        self.creatorAddress = creator.address 
    }

    execute {
        let metadata = DAAM.Metadata(
                creator: self.creatorAddress,
                metadata : "metadata",
                thumbnail: "thumbnail",
                file     : "file"
        )    
        log("Metadata Virtual Input Completed")        

        // Submit the NFT and deposit for review
        self.creatorRef.submitNFT(creator: self.creatorAddress, metadata: metadata)
        log("NFT Submitted")
    }
}
