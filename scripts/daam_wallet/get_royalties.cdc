// get_royalties.cdc

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V14      from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address, tokenID: UInt64 ):MetadataViews.Royalties? { //MetadataViews.Royalties? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V14.Collection{DAAM_V14.CollectionPublic}>(DAAM_V14.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    let nftRef = collectionRef?.borrowDAAM(id: id)
    let royalties = nftRef?.royalty
    return royalty
}
