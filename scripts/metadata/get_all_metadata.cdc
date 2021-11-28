// get_all_metadpata.cdc
// Used to get all Metadatas by all Creators

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun convert(_ metadata: {UInt64: DAAM_V7.Metadata}): [DAAM_V7.Metadata] {
    var mlist: [DAAM_V7.Metadata] = []
    for m in metadata.keys {
        mlist.append(metadata[m]!)
    }
    return mlist
}

pub fun main(): {Address: [DAAM_V7.Metadata]} // [[DAAM_V7.Metadata]]
{
    let creators = DAAM_V7.getCreators()
    var clist: { Address : [[DAAM_V7.Metadata]; 2] } = {}

    var metadataRef = getAccount(creators[0])
        .getCapability<&DAAM_V7.MetadataGenerator{DAAM_V7.MetadataGeneratorPublic}>(DAAM_V7.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    var metadatas: {UInt64: DAAM_V7.Metadata} = {}
    var mlist: {Address: [DAAM_V7.Metadata]} = {}

    for creator in creators {
        metadataRef = getAccount(creator)
            .getCapability<&DAAM_V7.MetadataGenerator{DAAM_V7.MetadataGeneratorPublic}>(DAAM_V7.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")
        metadatas = metadataRef.getMetadatas()  
        mlist.insert(key: creator, convert(metadatas) )
>>>>>>> master-emulator
    }
        
    //let convert_metadata = DAAM_V7.convertMetadata(metadata: mlist)
    //clist.insert(key: creator, convert_metadata)
    
    return mlist // clist
}
