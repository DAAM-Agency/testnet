// get_mids.cdc

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V10.MetadataGenerator{DAAM_V10.MetadataGeneratorPublic}>(DAAM_V10.metadataPublicPath)
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorPublic}>(DAAM_V14.metadataPublicPath)
>>>>>>> DAAM_V14
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}