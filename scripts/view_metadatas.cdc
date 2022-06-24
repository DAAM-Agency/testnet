// view_metadatas.cdc

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V14.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorPublic}>(DAAM_V14.metadataPublicPath)
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V15.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorPublic}>(DAAM_V15.metadataPublicPath)
>>>>>>> DAAM_V15
        .borrow()!
        
    return metadataRef.viewMetadatas()
}