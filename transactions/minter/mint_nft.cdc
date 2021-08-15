// mint_nft.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM_V2.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM_V2.Creator>(from: DAAM_V2.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")        
        let collection = creator.borrow<&{DAAM_V2.CollectionPublic}>(from: DAAM_V2.collectionStoragePath)
            ?? panic("Could not borrow Collection. Create a Collection first.")

        let metadataGenerator = creator.borrow<&DAAM_V2.MetadataGenerator>(from: DAAM_V2.metadataStoragePath)       
             ?? panic("Could not borrow Metadata Generator")
        let metadata <- metadataGenerator.generateMetadata(mid: mid)

        let requestGenerator = creator.borrow<&DAAM_V2.RequestGenerator>(from: DAAM_V2.requestStoragePath)!
        let request <- requestGenerator.getRequest(metadata: &metadata as &DAAM_V2.MetadataHolder)

        self.creatorRef.mintNFT(recipient: collection, metadata: <-metadata, request: <-request)     
        log("Minted NFT")
    }
}
