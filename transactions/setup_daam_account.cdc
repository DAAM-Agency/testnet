// setup_account.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM_NFT from 0xfd43f9148d4b725d

// This transaction is what an account would run to set itself up to receive NFTs
transaction
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM_NFT.Collection> (from: DAAM_NFT.collectionStoragePath) != nil { return }        
        let collection <- DAAM_NFT.createEmptyCollection()    // Create a new empty collection        
        acct.save<@DAAM_NFT.Collection> (<-collection, to: DAAM_NFT.collectionStoragePath) // save the new account
        // create a public capability for the collection
        acct.link<&DAAM_NFT.Collection>(DAAM_NFT.collectionPublicPath, target: DAAM_NFT.collectionStoragePath)
        log("DAAM Account Created, you now have a Collection to store NFTs'")
    }
}// transaction
