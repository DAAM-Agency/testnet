// reset_creator.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes <- creator.load<@DAAM_V1.Creator>(from: DAAM_V1.creatorStoragePath)!
        let requestRes <- creator.load<@DAAM_V1.RequestGenerator>(from: DAAM_V1.requestStoragePath)!
        destroy creatorRes
        destroy requestRes
        creator.unlink(DAAM_V1.creatorPrivatePath)
        creator.unlink(DAAM_V1.requestPrivatePath)
        log("Creator Removed")
    } 
}