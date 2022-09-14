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
        let mftRes <- self.acct.load<@MultiFungibleToken.MultiFungibleTokenManager>(from: MultiFungibleToken.MultiFungibleTokenStoragePath)!
        destroy mftRes
        log("MFT Wallet Destroyed")

        let mft <- MultiFungibleToken.createEmptyMultiFungibleTokenReceiver()    // Create a new empty collection
        self.acct.save<@MultiFungibleToken.MultiFungibleTokenManager>(<-mft, to: MultiFungibleToken.MultiFungibleTokenStoragePath) // save the new account
        log("MFT Wallet Re-Created & Updated")
    }
}
