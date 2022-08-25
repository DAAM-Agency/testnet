// get_collections.cdc

//import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V23 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [DAAM_V23.NFTCollectionDisplay] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V23.CollectionPublic}>(DAAM_V23.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getCollection()
}
