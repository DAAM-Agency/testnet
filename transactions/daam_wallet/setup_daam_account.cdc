// setup_daam_account.cdc
// Create A DAAM Wallet to store DAAM NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath) != nil {
            panic("You already have a DAAM Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM.Collection{DAAM.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
            log("DAAM Account Created. You have a DAAM Collection (Public) to store NFTs'")
        } else {
            log("DAAM Account Created. You have a DAAM Collection (Non-Public) to store NFTs'")
        }
    }
}
