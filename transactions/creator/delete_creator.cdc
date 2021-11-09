// delete_creator.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V5.Creator>(from: DAAM_V5.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V5.RequestGenerator>(from: DAAM_V5.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V5.creatorPrivatePath)
        creator.unlink(DAAM_V5.requestPrivatePath)
        creator.unlink(DAAM_V5.metadataPublicPath)
        log("Creator Removed")
    } 
}