// accept_default.cdc
// Creator selects Royality between 10% to 30%

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, percentage: UFix64) {
    //let creator     : AuthAccount
    let mid         : UInt64
    let percentage  : UFix64
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator

    prepare(creator: AuthAccount) {
        //self.creator = creator
        self.mid     = mid
        self.percentage  = percentage
        self.requestGen  = self.creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    pre { percentage >= 0.1 || percentage <= 0.3 }

    execute {
        self.requestGen.acceptDefault(mid: self.mid, metadataGen: self.metadataGen, percentage: self.percentage)
        log("Request Made")
    }
}
