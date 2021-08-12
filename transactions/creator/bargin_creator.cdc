// bargin_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, royality: {Address : UFix64} ) {
    let mid        : UInt64
    let royality   : {Address : UFix64}
    let creator    : AuthAccount
    let requestGen : &DAAM.RequestGenerator

    prepare(creator: AuthAccount) {
        self.mid = mid
        self.royality = royality
        self.creator = creator
        self.requestGen = self.creator.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
    }

    execute {
        DAAM.barginCreator(creator: self.creator, mid: self.mid, royality: self.royality)
        log("Request Answered")
    }
}
