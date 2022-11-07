// get_tokenIDs.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
