// get_tokenIDs.cdc

import NonFungibleToken from 0x1d7e57aa55817448
import DAAM from 0x7db4d10c78bad30a

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
