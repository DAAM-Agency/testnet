// delete_creator.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V15.Creator>(from: DAAM_V15.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V15.RequestGenerator>(from: DAAM_V15.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V15.MetadataGenerator>(from: DAAM_V15.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V15.creatorPrivatePath)
        creator.unlink(DAAM_V15.requestPrivatePath)
        creator.unlink(DAAM_V15.metadataPublicPath)
        log("Creator Removed")
    } 
}