// delete_creator.cdc

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V9.Creator>(from: DAAM_V9.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V9.RequestGenerator>(from: DAAM_V9.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V9.MetadataGenerator>(from: DAAM_V9.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V9.creatorPrivatePath)
        creator.unlink(DAAM_V9.requestPrivatePath)
        creator.unlink(DAAM_V9.metadataPublicPath)
        log("Creator Removed")
    } 
}