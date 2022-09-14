// Flow_0.39.3_Fix.cdc

import MultiFungibleToken from 0xf0653a06e7de7dbd
import NonFungibleToken   from 0x631e88ae7f1d7c20
import MetadataViews      from 0x631e88ae7f1d7c20
import DAAM_V23           from 0xa4ad5ea5c0bd2fba

transaction()
{
    let acct   : AuthAccount

    prepare(acct: AuthAccount) {
        self.acct   = acct
    }

    execute {
        if self.acct.borrow<&{DAAM_V23.CollectionPublic}>(from: DAAM_V23.collectionStoragePath) != nil {
            self.acct.unlink(DAAM_V23.collectionPublicPath)
            log("DAAM_V23.Account Created, you now have a Non-Public DAAM_V23 .Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }

        if self.acct.borrow<&{DAAM_V23.CollectionPublic}>(from: DAAM_V23.collectionStoragePath) != nil {
            self.acct.link<&{DAAM_V23.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V23.collectionPublicPath, target: DAAM_V23.collectionStoragePath)
            log("DAAM_V23.Account Created, you now have a Public DAAM_V23 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }

        let mftRes <- self.acct.load<@MultiFungibleToken.MultiFungibleTokenManager>(from: MultiFungibleToken.MultiFungibleTokenStoragePath)!
        destroy mftRes
        log("MFT Wallet Destroyed")

        let mft <- MultiFungibleToken.createEmptyMultiFungibleTokenReceiver()    // Create a new empty collection
        self.acct.save<@MultiFungibleToken.MultiFungibleTokenManager>(<-mft, to: MultiFungibleToken.MultiFungibleTokenStoragePath) // save the new account
        log("MFT Wallet Re-Created & Updated")
    }
}
