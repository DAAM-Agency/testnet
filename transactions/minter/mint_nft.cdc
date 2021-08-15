// mint_nft.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")        
        let collection = creator.borrow<&{DAAM.CollectionPublic}>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow Collection. Create a Collection first.")

        let metadataGenerator = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)       
             ?? panic("Could not borrow Metadata Generator")
        let metadata <- metadataGenerator.generateMetadata(mid: mid)

        let requestGenerator = creator.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
        let request <- requestGenerator.getRequest(metadata: &metadata as &DAAM.MetadataHolder)

        self.creatorRef.mintNFT(recipient: collection, metadata: <-metadata, request: <-request)     
        log("Minted NFT")
    }
}
