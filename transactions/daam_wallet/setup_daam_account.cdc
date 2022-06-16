// setup_daam_account.cdc
// Create A DAAM_V13 Wallet to store DAAM_V13 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V13             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V13.Collection>(from: DAAM_V13.collectionStoragePath) != nil {
            panic("You already have a DAAM_V13 Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V13.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V13.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V13.Collection{DAAM_V13.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V13.collectionPublicPath, target: DAAM_V13.collectionStoragePath)
            log("DAAM_V13 Account Created. You have a DAAM_V13 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V13 Account Created. You have a DAAM_V13 Collection (Non-Public) to store NFTs'")
        }
    }
}
