// delete_creator.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V4.Creator>(from: DAAM_V4.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V4.RequestGenerator>(from: DAAM_V4.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V4.MetadataGenerator>(from: DAAM_V4.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V4.creatorPrivatePath)
        creator.unlink(DAAM_V4.requestPrivatePath)
        creator.unlink(DAAM_V4.metadataPublicPath)
        log("Creator Removed")
    } 
}