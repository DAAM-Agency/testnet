// get_mft_balances.cdc

import FungibleToken    from 0x9a0766d93b6608b7
import MultiFungibleToken from 0xf0653a06e7de7dbd

pub fun main(account: Address): {String : UFix64} { // { FungibleToken Type.instance : balance }
    let mftRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
        (MultiFungibleToken.MultiFungibleTokenBalancePath)
        .borrow()
    
    return mftRef!.getStorageBalances()!
}
