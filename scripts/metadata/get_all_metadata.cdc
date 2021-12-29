// get_all_metadpata.cdc
// Used to get all Metadatas by all Creators

import DAAM from 0xfd43f9148d4b725d

pub fun convert(_ metadata: {UInt64: DAAM.Metadata}): [DAAM.Metadata] {
    var mlist: [DAAM.Metadata] = []
    for m in metadata.keys {
        mlist.append(metadata[m]!)
    }
    return mlist
}

pub fun main(): {Address: [[DAAM.Metadata];2] } // [[DAAM.Metadata]]
{
    let creators = DAAM.getCreators()
    var clist: { Address : [[DAAM.Metadata];2] } = {}

    var metadataRef = getAccount(creators[0])
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPrivatePath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    var metadatas: {UInt64: DAAM.Metadata}  = {}
    var mlist: {Address: [DAAM.Metadata]}   = {}
    //var convert_metadata: [DAAM.Metadata;2] = [DAAM.Metadata]

    for creator in creators {
        metadataRef = getAccount(creator)
            .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPrivatePath)
            .borrow() ?? panic("Could not borrow capability from Metadata")
        metadatas = metadataRef.getMetadatas()  
        mlist.insert(key: creator, convert(metadatas) )
        let convert_metadata = DAAM.convertMetadata(metadata: mlist[creator]!)
        clist.insert(key: creator, convert_metadata)
    }   
    
    return clist
}
