// delete_creator.cdc

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V6.Creator>(from: DAAM_V6.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V6.RequestGenerator>(from: DAAM_V6.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V6.MetadataGenerator>(from: DAAM_V6.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V6.creatorPrivatePath)
        creator.unlink(DAAM_V6.requestPrivatePath)
        creator.unlink(DAAM_V6.metadataPublicPath)
        log("Creator Removed")
    } 
}