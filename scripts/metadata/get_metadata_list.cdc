// get_metadata_list.cdc
// Used to get a all Metadatas from a Creator

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [[DAAM_V7.Metadata];2]
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V7.MetadataGenerator{DAAM_V7.MetadataGeneratorPublic}>(DAAM_V7.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    let metadatas = metadataRef.getMetadatas()
    var mlist: [DAAM_V7.Metadata] = []
    for m in metadatas.keys {
        mlist.append(metadatas[m]!)
    }
    let convert_metadata = DAAM_V7.convertMetadata(metadata: mlist)
    
    return convert_metadata
}
