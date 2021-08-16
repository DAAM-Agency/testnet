// reset_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM.Creator>(from: DAAM.creatorStoragePath)
        let metadataRes <- creator.load<@DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        let requestRes  <- creator.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
        destroy creatorRes
        destroy requestRes
        creator.unlink(DAAM.creatorPrivatePath)
        creator.unlink(DAAM.requestPrivatePath)
        log("Creator Removed")
    } 
}