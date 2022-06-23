// get_royalties.cdc

import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

pub fun main(account: Address, tokenID: UInt64 ):MetadataViews.Royalties? { //MetadataViews.Royalties? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM.Collection{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef!.borrowDAAM(id: tokenID)
    let royalties = ref.royalty //as &MetadataViews.Royalities
    return royalties
}
