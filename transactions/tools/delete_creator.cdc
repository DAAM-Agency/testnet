// delete_creator.cdc

import DAAM_V11 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_V11.Creator>(from: DAAM_V11.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_V11.RequestGenerator>(from: DAAM_V11.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_V11.MetadataGenerator>(from: DAAM_V11.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V11.creatorPrivatePath)
        creator.unlink(DAAM_V11.requestPrivatePath)
        creator.unlink(DAAM_V11.metadataPublicPath)
        log("Creator Removed")
    } 
}