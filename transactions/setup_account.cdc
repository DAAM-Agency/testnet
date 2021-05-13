// setup_account.cdc

import NonFungibleToken from 0x120e725050340cab
import MarketPalace from 0x045a1763c93006ca
// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(acct: AuthAccount) {

        // Return early if the account already has a collection
        if acct.borrow<&MarketPalace.Collection{NonFungibleToken.CollectionPublic}>
        (from: MarketPalace.collectionStoragePath) != nil { return }        
        let collection <- MarketPalace.createEmptyCollection()    // Create a new empty collection        
        acct.save(<-collection, to: MarketPalace.collectionStoragePath)   // save it to the account

        // create a public capability for the collection
        acct.link<&{NonFungibleToken.CollectionPublic}>(MarketPalace.collectionPublicPath, target: MarketPalace.collectionStoragePath)

        log("D.A.A.M Account Created, you now have a Collection to store NFTs'")
    }
}
