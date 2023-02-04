// check_mft.cdc

import FungibleToken      from 0xf233dcee88fe0abe
import MultiFungibleToken from 0x229e7617283d5085

pub fun main(account: Address): Bool {
    let collectionRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
        (MultiFungibleToken.MultiFungibleTokenBalancePath)
        .borrow()
    
    return (collectionRef != nil)
}
