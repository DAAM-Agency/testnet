// setup_daam_account.cdc
// Create A DAAM_V14 Wallet to store DAAM_V14 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V14             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V14.Collection>(from: DAAM_V14.collectionStoragePath) != nil {
            panic("You already have a DAAM_V14 Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V14.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V14.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V14.Collection{DAAM_V14.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V14.collectionPublicPath, target: DAAM_V14.collectionStoragePath)
            log("DAAM_V14 Account Created. You have a DAAM_V14 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V14 Account Created. You have a DAAM_V14 Collection (Non-Public) to store NFTs'")
        }
    }
}
