// reset_creator.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes <- creator.load<@DAAM_V2.Creator>(from: DAAM_V2.creatorStoragePath)!
        let requestRes <- creator.load<@DAAM_V2.RequestGenerator>(from: DAAM_V2.requestStoragePath)!
        destroy creatorRes
        destroy requestRes
        creator.unlink(DAAM_V2.creatorPrivatePath)
        creator.unlink(DAAM_V2.requestPrivatePath)
        log("Creator Removed")
    } 
}