// reset_creator.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes <- creator.load<@DAAM.Creator>(from: DAAM.creatorStoragePath)!
        let requestRes <- creator.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
        destroy creatorRes
        destroy requestRes
        creator.unlink(DAAM.creatorPrivatePath)
        creator.unlink(DAAM.requestPrivatePath)
        log("Creator Removed")
    } 
}