// mint_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(elm: UInt16) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")
        
        let collection = creator.borrow<&{NonFungibleToken.CollectionPublic}>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow Collection")

        let metadataGenerator = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)       
             ?? panic("Could not borrow Metadata Generator")

        let metadata <- metadataGenerator.generateMetadata(elm)!

        self.creatorRef.mintNFT(recipient: collection, metadata: <-metadata)     
        log("Minted NFT")
    }
}
