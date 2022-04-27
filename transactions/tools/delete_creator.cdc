// delete_creator.cdc

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V10.Creator>(from: DAAM_V10.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V10.RequestGenerator>(from: DAAM_V10.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V10.MetadataGenerator>(from: DAAM_V10.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V10.creatorPrivatePath)
        creator.unlink(DAAM_V10.requestPrivatePath)
        creator.unlink(DAAM_V10.metadataPublicPath)
        log("Creator Removed")
    } 
}