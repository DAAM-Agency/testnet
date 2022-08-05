// get_NFT_file.cdc
// View the NFT file

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V21          from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address, tokenID: UInt64 ): {String: MetadataViews.Media}
{
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V21.CollectionPublic}>(DAAM_V21.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef.borrowDAAM(id: tokenID)
    let file = ref.file
    return file
}
