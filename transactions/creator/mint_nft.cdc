// mint_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM             from 0x51e2c02e69b53477

transaction(mid: UInt64) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")        
        let collection = creator.borrow<&{NonFungibleToken.CollectionPublic}>(from: DAAM.collectionStoragePath)
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
