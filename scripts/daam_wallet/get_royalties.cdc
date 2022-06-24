// get_royalties.cdc

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V15          from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address, tokenID: UInt64 ):MetadataViews.Royalties? { //MetadataViews.Royalties? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V15.Collection{DAAM_V15.CollectionPublic}>(DAAM_V15.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef!.borrowDAAM(id: tokenID)
    let royalties = ref.royalty //as &MetadataViews.Royalities
    return royalties
}
