// get_mft_balances.cdc

import FungibleToken      from 0xf233dcee88fe0abe
import MultiFungibleToken from 0x229e7617283d5085

pub fun main(account: Address): {String : UFix64} { // { FungibleToken Type.instance : balance }
    let mftRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
        (MultiFungibleToken.MultiFungibleTokenBalancePath)
        .borrow()
    
    return mftRef!.getStorageBalances()!
}
