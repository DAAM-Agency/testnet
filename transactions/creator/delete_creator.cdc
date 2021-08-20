// delete_creator.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V3.Creator>(from: DAAM.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V3.RequestGenerator>(from: DAAM.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V3.MetadataGenerator>(from: DAAM.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V3.creatorPrivatePath)
        creator.unlink(DAAM_V3.requestPrivatePath)
        creator.unlink(DAAM_V3.metadataPublicPath)
        log("Creator Removed")
    } 
}