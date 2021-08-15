// reset_creator.cdc

import DAAM from 0xf8d6e0586b0a20c7

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