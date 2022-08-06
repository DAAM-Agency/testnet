// create_wallets_and_deposit.cdc

import MultiFungibleToken from 0xf0653a06e7de7dbd

transaction()
{
    let mftRef : &MultiFungibleToken.MultiFungibleTokenManager
    let acct   : AuthAccount

    prepare(acct: AuthAccount) {
        self.acct   = acct
        self.mftRef = acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager>(from: MultiFungibleToken.MultiFungibleTokenStoragePath)
            ?? panic("Create a DAAM_V21 Wallet frist.")
    }

    execute {
        MultiFungibleToken.createMissingWalletsAndDeposit(self.acct, self.mftRef)
    }
}
