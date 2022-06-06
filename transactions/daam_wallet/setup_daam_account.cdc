// setup_daam_account.cdc
// Create A DAAM_V12 Wallet to store DAAM_V12 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V12             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V12.Collection>(from: DAAM_V12.collectionStoragePath) != nil {
            panic("You already have a DAAM_V12 Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V12.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V12.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V12.Collection{DAAM_V12.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V12.collectionPublicPath, target: DAAM_V12.collectionStoragePath)
            log("DAAM_V12 Account Created. You have a DAAM_V12 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V12 Account Created. You have a DAAM_V12 Collection (Non-Public) to store NFTs'")
        }
    }
}
