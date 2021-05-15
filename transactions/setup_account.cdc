// setup_account.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM_NFT from 0xfd43f9148d4b725d
// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(acct: AuthAccount) {

        // Return early if the account already has a collection
        if acct.borrow<&DAAM_NFT.Collection{NonFungibleToken.CollectionPublic}>
        (from: DAAM_NFT.collectionStoragePath) != nil { return }        
        let collection <- DAAM_NFT.createEmptyCollection()    // Create a new empty collection        
        acct.save(<-collection, to: DAAM_NFT.collectionStoragePath)   // save it to the account

        // create a public capability for the collection
        acct.link<&{NonFungibleToken.CollectionPublic}>(DAAM_NFT.collectionPublicPath, target: DAAM_NFT.collectionStoragePath)

        log("D.A.A.M Account Created, you now have a Collection to store NFTs'")
    }
}
