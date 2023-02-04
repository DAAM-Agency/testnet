// get_NFT_file.cdc
// View the NFT file

import MetadataViews from 0x1d7e57aa55817448
import DAAM          from 0x7db4d10c78bad30a

pub fun main(account: Address, tokenID: UInt64 ): {String: MetadataViews.Media}
{
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef.borrowDAAM(id: tokenID)
    let file = ref.file
    return file
}
