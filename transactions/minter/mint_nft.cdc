// mint_nft.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM_V5.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM_V5.Creator>(from: DAAM_V5.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")        
        let collection = creator.borrow<&{DAAM_V5.CollectionPublic}>(from: DAAM_V5.collectionStoragePath)
            ?? panic("Could not borrow Collection. Create a Collection first.")

        let metadataGenerator = creator.borrow<&DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)       
             ?? panic("Could not borrow Metadata Generator")
        let metadata <- metadataGenerator.generateMetadata(mid: mid)

        let requestGenerator = creator.borrow<&DAAM_V5.RequestGenerator>(from: DAAM_V5.requestStoragePath)!
        let request <- requestGenerator.getRequest(metadata: &metadata as &DAAM_V5.MetadataHolder)

        self.creatorRef.mintNFT(recipient: collection, metadata: <-metadata, request: <-request)     
        log("Minted NFT")
    }
}
