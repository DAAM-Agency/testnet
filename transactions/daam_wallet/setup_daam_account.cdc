// setup_daam_account.cdc
// Create A DAAM_V8.Wallet to store DAAM_V8.NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V8             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    var msg: String

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V8.Collection> (from: DAAM_V8.collectionStoragePath) != nil { panic("You already have a DAAM_V8.Collection.") }
        
        self.msg = ""
        let collection <- DAAM_V8.createDAAM_V8.ollection()    // Create a new empty collection
        
        acct.save<@DAAM_V8.Collection>(<-collection, to: DAAM_V8.collectionStoragePath) // save the new account
        
        if public {
            acct.link<&DAAM_V8.Collection{DAAM_V8.CollectionPublic, NonFungibleToken.CollectionPublic}>(DAAM_V8.collectionPublicPath, target: DAAM_V8.collectionStoragePath)
        } else {
            self.msg = "Non-"
        }
        
        log("DAAM_V8.Account Created. You have a ".concat(self.msg).concat("Public DAAM_V8.Collection to store NFTs'"))
    }
}
