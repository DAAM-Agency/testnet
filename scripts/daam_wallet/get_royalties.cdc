// get_royalties.cdc
// Get all the royalties from an NFT

import MetadataViews from 0x1d7e57aa55817448
import DAAM          from 0x7db4d10c78bad30a

pub fun main(account: Address, tokenID: UInt64 ):MetadataViews.Royalties? {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef.borrowDAAM(id: tokenID)
    let royalties = ref.royalty
    return royalties
}
