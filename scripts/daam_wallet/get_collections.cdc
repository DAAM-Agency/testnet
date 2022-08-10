// get_collections.cdc

import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [MetadataViews.NFTCollectionDisplay] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getCollection()
}
