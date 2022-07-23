// get_mft_balances.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import MultiFungibleToken from 0x192440c99cb17282

pub fun main(account: Address): {String : UFix64} {
    let collectionRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
        (MultiFungibleToken.MultiFungibleTokenBalancePath)
        .borrow()
    
    return collectionRef!.getBalances()!
}
