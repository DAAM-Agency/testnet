// get_collections.cdc

//import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): {String: DAAM.NFTCollectionDisplay} {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let list = collectionRef.getCollection()
    var value: {String: DAAM.NFTCollectionDisplay} = {}
    for col in list { value.insert(key: col.display.name, col) }

    return value
}
