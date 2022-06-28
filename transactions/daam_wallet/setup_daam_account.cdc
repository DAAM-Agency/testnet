// setup_daam_account.cdc
// Create A DAAM_V17 Wallet to store DAAM_V17 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V17             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V17.Collection>(from: DAAM_V17.collectionStoragePath) != nil {
            panic("You already have a DAAM_V17 Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V17.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V17.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V17.Collection{DAAM_V17.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V17.collectionPublicPath, target: DAAM_V17.collectionStoragePath)
            log("DAAM_V17 Account Created. You have a DAAM_V17 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V17 Account Created. You have a DAAM_V17 Collection (Non-Public) to store NFTs'")
        }
    }
}
