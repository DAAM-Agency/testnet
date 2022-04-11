// delete_creator.cdc

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V8.Creator>(from: DAAM_V8.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V8.RequestGenerator>(from: DAAM_V8.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V8.MetadataGenerator>(from: DAAM_V8.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V8.creatorPrivatePath)
        creator.unlink(DAAM_V8.requestPrivatePath)
        creator.unlink(DAAM_V8.metadataPublicPath)
        log("Creator Removed")
    } 
}