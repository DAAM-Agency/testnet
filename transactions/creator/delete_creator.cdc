// delete_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM.Creator>(from: DAAM.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
        let metadataRes <- creator.load<@DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM.creatorPrivatePath)
        creator.unlink(DAAM.requestPrivatePath)
        creator.unlink(DAAM.metadataPublicPath)
        log("Creator Removed")
    } 
}