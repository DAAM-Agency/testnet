// create_wallets_and_deposit.cdc

import MultiFungibleToken from 0xfa1c6cfe182ee46b

transaction()
{
    let mftRef : &MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}

    prepare(acct: AuthAccount) {
        self.mftRef = acct.borrow<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
            (from: MultiFungibleToken.MultiFungibleTokenStoragePath) ?? panic("Create a DAAM Wallet frist.")
    }

    execute { self.mftRef.createMissingWalletsAndDeposit() }
}
