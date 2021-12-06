// get_metadata_list.cdc
// Used to get a all Metadatas from a Creator

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address):[[DAAM.Metadata];2]
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    let metadatas = metadataRef.getMetadatas()
    var mlist: [DAAM.Metadata] = []
    for m in metadatas.keys {
        mlist.append(metadatas[m]!)
    }
    let convert_metadata = DAAM.convertMetadata(metadata: mlist)

    return convert_metadata
}
