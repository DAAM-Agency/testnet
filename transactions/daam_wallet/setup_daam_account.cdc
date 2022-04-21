// setup_daam_account.cdc
// Create A DAAM Wallet to store DAAM NFTs

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(public: Bool)
{
    let public: Bool

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath) != nil {
            panic("You already have a DAAM Collection.")
        }
        self.public = public
    }

    execute {
        let collection <- DAAM.createDAAMCollection()    // Create a new empty collection
        acct.save<@DAAM.Collection>(<-collection, to: DAAM.collectionStoragePath) // save the new account
        
        if self.public {
            acct.link<&DAAM.Collection{DAAM.CollectionPublic, NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
            log("DAAM Account Created. You have a DAAM Collection (Public) to store NFTs'"))
        } else {
            log("DAAM Account Created. You have a DAAM Collection (Non-Public) to store NFTs'"))
        }
    }
}
