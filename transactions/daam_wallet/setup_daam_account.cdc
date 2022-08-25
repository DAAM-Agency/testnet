// setup_daam_account.cdc
// Create A DAAM_V22 Wallet to store DAAM_V22 NFTs
// Includes: /multitoken/setup_mft_receiver.cdc

import NonFungibleToken   from 0x631e88ae7f1d7c20
import FungibleToken      from 0x9a0766d93b6608b7
import MetadataViews      from 0x631e88ae7f1d7c20
import MultiFungibleToken from 0xfa1c6cfe182ee46b
import DAAM_V22               from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath) != nil {
            panic("You already have a DAAM_V22 Collection.")
        }
        if acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>(from: MultiFungibleToken.MultiFungibleTokenStoragePath) != nil {
            panic("You already have a Multi-FungibleToken-Manager.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V22.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V22.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&{DAAM_V22.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V22.collectionPublicPath, target: DAAM_V22.collectionStoragePath)
            log("DAAM_V22.Account Created. You have a DAAM_V22 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V22.Account Created. You have a DAAM_V22 Collection (Non-Public) to store NFTs'")
        }

        // MultiFungibleToken
        let mft <- MultiFungibleToken.createEmptyMultiFungibleTokenReceiver()    // Create a new empty collection
        self.acct.save<@MultiFungibleToken.MultiFungibleTokenManager>(<-mft, to: MultiFungibleToken.MultiFungibleTokenStoragePath) // save the new account
        
        self.acct.link<&MultiFungibleToken.MultiFungibleTokenManager{FungibleToken.Receiver}>
            (MultiFungibleToken.MultiFungibleTokenReceiverPath, target: MultiFungibleToken.MultiFungibleTokenStoragePath)
        
        self.acct.link<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
            (MultiFungibleToken.MultiFungibleTokenBalancePath, target: MultiFungibleToken.MultiFungibleTokenStoragePath)
        
        log("MultiFungibleToken Receiver Created")
    }
}
