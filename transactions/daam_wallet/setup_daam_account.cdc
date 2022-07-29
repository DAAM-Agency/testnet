// setup_daam_account.cdc
// Create A DAAM_V21 Wallet to store DAAM_V21 NFTs
// Includes: /multitoken/setup_mft_receiver.cdc

import NonFungibleToken   from 0x631e88ae7f1d7c20
import FungibleToken      from 0x9a0766d93b6608b7
import MetadataViews      from 0x631e88ae7f1d7c20
import MultiFungibleToken from 0xf0653a06e7de7dbd
import DAAM_V21           from 0xa4ad5ea5c0bd2fba

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V21.Collection>(from: DAAM_V21.collectionStoragePath) != nil {
            panic("You already have a DAAM_V21 Collection.")
        }
        if acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>(from: MultiFungibleToken.MultiFungibleTokenStoragePath) != nil {
            panic("You already have a Multi-FungibleToken-Manager.")
        }
        self.public = public
        self.acct   = acct
    }

    execute {
        let collection <- DAAM_V21.createEmptyCollection()    // Create a new empty collection
        self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM_V21.collectionStoragePath) // save the new account
        
        if self.public {
            self.acct.link<&{DAAM_V21.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V21.collectionPublicPath, target: DAAM_V21.collectionStoragePath)
            log("DAAM_V21 Account Created. You have a DAAM_V21 Collection (Public) to store NFTs'")
        } else {
            log("DAAM_V21 Account Created. You have a DAAM_V21 Collection (Non-Public) to store NFTs'")
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
