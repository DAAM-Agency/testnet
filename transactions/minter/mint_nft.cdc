// mint_nft.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM_V3.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")        
        let collection = creator.borrow<&{DAAM_V3.CollectionPublic}>(from: DAAM_V3.collectionStoragePath)
            ?? panic("Could not borrow Collection. Create a Collection first.")

        let metadataGenerator = creator.borrow<&DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)       
             ?? panic("Could not borrow Metadata Generator")
        let metadata <- metadataGenerator.generateMetadata(mid: mid)

        let requestGenerator = creator.borrow<&DAAM_V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)!
        let request <- requestGenerator.getRequest(metadata: &metadata as &DAAM_V3.MetadataHolder)

        self.creatorRef.mintNFT(recipient: collection, metadata: <-metadata, request: <-request)     
        log("Minted NFT")
    }
}
