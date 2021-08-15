// reset_creator.cdc

import DAAM_V3.V2 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes <- creator.load<@DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)!
        let requestRes <- creator.load<@DAAM_V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)!
        destroy creatorRes
        destroy requestRes
        creator.unlink(DAAM_V3.creatorPrivatePath)
        creator.unlink(DAAM_V3.requestPrivatePath)
        log("Creator Removed")
    } 
}