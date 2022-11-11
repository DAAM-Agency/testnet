// check_mft.cdc

import FungibleToken    from 0x9a0766d93b6608b7
import MultiFungibleToken from 0xf0653a06e7de7dbd

pub fun main(account: Address): Bool {
    let collectionRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{MultiFungibleToken.MultiFungibleTokenBalance}>
        (MultiFungibleToken.MultiFungibleTokenBalancePath)
        .borrow()
    
    return (collectionRef != nil)
}
 