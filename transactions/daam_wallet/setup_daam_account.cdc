// setup_daam_account.cdc
// Create A DAAM Wallet to store DAAM NFTs
// Includes: /multitoken/setup_mft_receiver.cdc

import NonFungibleToken   from 0x1d7e57aa55817448
import FungibleToken      from 0xf233dcee88fe0abe
import MetadataViews      from 0x1d7e57aa55817448
import MultiFungibleToken from 0x229e7617283d5085
import DAAM               from 0x7db4d10c78bad30a

transaction(public: Bool)
{
    let public: Bool
    let acct: AuthAccount
    let have_collection: Bool
    let have_mft: Bool

    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath) != nil {
            self.have_collection = true
            //panic("You already have a DAAM Collection.")
        } else {
            self.have_collection = false
        }

        if acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>(from: MultiFungibleToken.MultiFungibleTokenStoragePath) != nil {
            self.have_mft = true
            //panic("You already have a Multi-FungibleToken-Manager.")
        } else {
            self.have_mft = false
        }

        self.public = public
        self.acct   = acct
    }

    execute {
        if !self.have_collection {
            let collection <- DAAM.createEmptyCollection()    // Create a new empty collection
            self.acct.save<@NonFungibleToken.Collection>(<-collection, to: DAAM.collectionStoragePath) // save the new account
            
            if self.public {
                self.acct.link<&DAAM.Collection{DAAM.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
                log("DAAM Account Created. You have a DAAM Collection (Public) to store NFTs'")
            } else {
                log("DAAM Account Created. You have a DAAM Collection (Non-Public) to store NFTs'")
            }
        }

        if !self.have_mft {
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
}
 