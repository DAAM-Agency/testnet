// get_collections.cdc

//import MetadataViews from 0x631e88ae7f1d7c20
import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [DAAM.NFTCollectionDisplay] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getCollection()
}
