// get_collections.cdc

//import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM_V23 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V23.NFTCollectionDisplay} {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V23.CollectionPublic}>(DAAM_V23.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let list = collectionRef.getCollection()
    var value: {String: DAAM_V23.NFTCollectionDisplay} = {}
    for col in list { value.insert(key: col.display.name, col) }

    return value
}
