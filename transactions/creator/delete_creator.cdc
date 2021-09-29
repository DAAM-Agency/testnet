// delete_creator.cdc

import DAAM_V3.V3 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V3.V3.Creator>(from: DAAM_V3.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V3.V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V3.V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V3.V3.creatorPrivatePath)
        creator.unlink(DAAM_V3.V3.requestPrivatePath)
        creator.unlink(DAAM_V3.V3.metadataPublicPath)
        log("Creator Removed")
    } 
}