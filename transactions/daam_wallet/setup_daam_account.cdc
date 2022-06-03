// setup_daam_account.cdc
// Create A DAAM_V11 Wallet to store DAAM_V11 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V11             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V11.Collection>(from: DAAM_V11.collectionStoragePath) != nil {
            panic("You already have a DAAM_V11 Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V11.createDAAM_V11Collection()    // Create a new empty collection
        self.acct.save<@DAAM_V11.Collection>(<-collection, to: DAAM_V11.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V11.Collection{DAAM_V11.CollectionPublic, NonFungibleToken.CollectionPublic}>(DAAM_V11.collectionPublicPath, target: DAAM_V11.collectionStoragePath)
            log("DAAM_V11 Account Created. You have a DAAM_V11 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V11 Account Created. You have a DAAM_V11 Collection (Non-Public) to store NFTs'")
        }
    }
}
