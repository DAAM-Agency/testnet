// setup_daam_account.cdc
<<<<<<< HEAD
// Create A DAAM_V14 Wallet to store DAAM_V14 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V14             from 0xa4ad5ea5c0bd2fba
=======
// Create A DAAM_V15 Wallet to store DAAM_V15 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V15             from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
<<<<<<< HEAD
        if acct.borrow<&DAAM_V14.Collection>(from: DAAM_V14.collectionStoragePath) != nil {
            panic("You already have a DAAM_V14 Collection.")
=======
        if acct.borrow<&DAAM_V15.Collection>(from: DAAM_V15.collectionStoragePath) != nil {
            panic("You already have a DAAM_V15 Collection.")
>>>>>>> DAAM_V15
        }
        self.public = public
        self.acct   = acct
    }

    execute {
<<<<<<< HEAD
        let collection <- DAAM_V14.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V14.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V14.Collection{DAAM_V14.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V14.collectionPublicPath, target: DAAM_V14.collectionStoragePath)
            log("DAAM_V14 Account Created. You have a DAAM_V14 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V14 Account Created. You have a DAAM_V14 Collection (Non-Public) to store NFTs'")
=======
        let collection <- DAAM_V15.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V15.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V15.Collection{DAAM_V15.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V15.collectionPublicPath, target: DAAM_V15.collectionStoragePath)
            log("DAAM_V15 Account Created. You have a DAAM_V15 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V15 Account Created. You have a DAAM_V15 Collection (Non-Public) to store NFTs'")
>>>>>>> DAAM_V15
        }
    }
}
