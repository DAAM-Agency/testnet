// get_mft_balances.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import MultiFungibleToken from 0xfa1c6cfe182ee46b

pub fun main(account: Address): {String : UFix64} { // { FungibleToken Type.instance : balance }
    let collectionRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
        (MultiFungibleToken.MultiFungibleTokenBalancePath)
        .borrow()
    
    return collectionRef!.getStorageBalances()!
}
