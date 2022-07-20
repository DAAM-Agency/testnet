// check_mft.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import MultiFungibleToken from 0x192440c99cb17282

pub fun main(account: Address): Bool {
    let collectionRef = getAccount(account)
        .getCapability<&MultiFungibleToken.MultiFungibleTokenManager{FungibleToken.Receiver}>
        (MultiFungibleToken.MultiFungibleTokenPublicPath)
        .borrow()
    
    return (collectionRef != nil)
}
