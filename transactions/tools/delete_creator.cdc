// delete_creator.cdc

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V7.Creator>(from: DAAM_V7.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V7.RequestGenerator>(from: DAAM_V7.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V7.MetadataGenerator>(from: DAAM_V7.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V7.creatorPrivatePath)
        creator.unlink(DAAM_V7.requestPrivatePath)
        creator.unlink(DAAM_V7.metadataPublicPath)
        log("Creator Removed")
    } 
}