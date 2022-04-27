// setup_daam_account.cdc
// Create A DAAM_V10.Wallet to store DAAM_V10.NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V10             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V10.Collection>(from: DAAM_V10.collectionStoragePath) != nil {
            panic("You already have a DAAM Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V10.createDAAMCollection()    // Create a new empty collection
        self.acct.save<@DAAM_V10.Collection>(<-collection, to: DAAM_V10.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V10.Collection{DAAM_V10.CollectionPublic, NonFungibleToken.CollectionPublic}>(DAAM_V10.collectionPublicPath, target: DAAM_V10.collectionStoragePath)
            log("DAAM Account Created. You have a DAAM Collection (Public) to store NFTs'")
        } else {
            log("DAAM Account Created. You have a DAAM Collection (Non-Public) to store NFTs'")
        }
    }
}
