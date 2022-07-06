// setup_daam_account.cdc
// Create A DAAM_V18 Wallet to store DAAM_V18 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V18             from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V18.Collection>(from: DAAM_V18.collectionStoragePath) != nil {
            panic("You already have a DAAM Collection.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V18.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V18.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&{DAAM_V18.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>
            (DAAM_V18.collectionPublicPath, target: DAAM_V18.collectionStoragePath)
            log("DAAM Account Created. You have a DAAM Collection (Public) to store NFTs'")
        } else {
            log("DAAM Account Created. You have a DAAM_V18 Collection (Non-Public) to store NFTs'")
        }
    }
}
