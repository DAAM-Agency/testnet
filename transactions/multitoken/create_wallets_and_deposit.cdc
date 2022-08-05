// create_wallets_and_deposit.cdc

import MultiFungibleToken from 0xfa1c6cfe182ee46b

transaction()
{
    let mftRef : &MultiFungibleToken.MultiFungibleTokenManager
    let acct   : AuthAccount

    prepare(acct: AuthAccount) {
        self.acct   = acct
        self.mftRef = acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager>(from: MultiFungibleToken.MultiFungibleTokenStoragePath)
            ?? panic("Create a DAAM Wallet frist.")
    }

    execute {
        MultiFungibleToken.createMissingWalletsAndDeposit(self.acct, self.mftRef)
    }
}
