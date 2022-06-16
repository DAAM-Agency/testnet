// setup_daam_account.cdc
<<<<<<< HEAD
// Create A DAAM_V10.Wallet to store DAAM_V10.NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V10             from 0xa4ad5ea5c0bd2fba
=======
// Create A DAAM_V14 Wallet to store DAAM_V14 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V14             from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
<<<<<<< HEAD
        if acct.borrow<&DAAM_V10.Collection>(from: DAAM_V10.collectionStoragePath) != nil {
            panic("You already have a DAAM Collection.")
=======
        if acct.borrow<&DAAM_V14.Collection>(from: DAAM_V14.collectionStoragePath) != nil {
            panic("You already have a DAAM_V14 Collection.")
>>>>>>> DAAM_V14
        }
        self.public = public
        self.acct   = acct
    }

    execute {
<<<<<<< HEAD
        let collection <- DAAM_V10.createDAAMCollection()    // Create a new empty collection
        self.acct.save<@DAAM_V10.Collection>(<-collection, to: DAAM_V10.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V10.Collection{DAAM_V10.CollectionPublic, NonFungibleToken.CollectionPublic}>(DAAM_V10.collectionPublicPath, target: DAAM_V10.collectionStoragePath)
            log("DAAM Account Created. You have a DAAM Collection (Public) to store NFTs'")
=======
        let collection <- DAAM_V14.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V14.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&DAAM_V14.Collection{DAAM_V14.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V14.collectionPublicPath, target: DAAM_V14.collectionStoragePath)
            log("DAAM_V14 Account Created. You have a DAAM_V14 Collection (Public) to store NFTs'")
>>>>>>> DAAM_V14
        } else {
            log("DAAM_V14 Account Created. You have a DAAM_V14 Collection (Non-Public) to store NFTs'")
        }
    }
}
