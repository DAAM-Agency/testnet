// get_NFT_file.cdc
// View the NFT file

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Mainnet          from 0xfd43f9148d4b725d

pub fun main(account: Address, tokenID: UInt64 ): {String: MetadataViews.Media}
{
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_Mainnet.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    let ref = collectionRef.borrowDAAM_Mainnet(id: tokenID)
    let file = ref.file
    return file
}
