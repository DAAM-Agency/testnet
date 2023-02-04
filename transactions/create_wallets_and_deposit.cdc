// create_wallets_and_deposit.cdc

import MultiFungibleToken from 0x229e7617283d5085

transaction()
{
    let mftRef : &MultiFungibleToken.MultiFungibleTokenManager
    let acct   : AuthAccount

    prepare(acct: AuthAccount) {
        self.acct   = acct
        self.mftRef = acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager>(from: MultiFungibleToken.MultiFungibleTokenStoragePath)
            ?? panic("Create a DAAM_V23 Wallet frist.")
    }

    execute {
        MultiFungibleToken.createMissingWalletsAndDeposit(self.acct, self.mftRef)
    }
}
