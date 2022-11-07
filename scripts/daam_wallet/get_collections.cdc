// get_collections.cdc

//import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_Mainnet.NFTCollectionDisplay} {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_Mainnet.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let list = collectionRef.getCollection()
    //var value: {String: DAAM_Mainnet.NFTCollectionDisplay} = {}
    //for col in list { value.insert(key: col.display.name, col) }
    //return value
    return list
}
