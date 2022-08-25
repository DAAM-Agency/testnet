// get_royalties.cdc
// Get all the royalties from an NFT

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V22          from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address, tokenID: UInt64 ):MetadataViews.Royalties? {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V22.CollectionPublic}>(DAAM_V22.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef.borrowDAAM_V22.id: tokenID)
    let royalties = ref.royalty
    return royalties
}
