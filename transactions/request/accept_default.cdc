// accept_default.cdc
// Creator selects Royality between 10% to 30%

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64) {
    let mid         : UInt64
    let percentage  : UFix64
    let requestGen  : &DAAM_V8.RequestGenerator
    let metadataGen : &DAAM_V8.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.mid     = mid
        self.percentage  = percentage
        self.requestGen  = creator.borrow<&DAAM_V8.RequestGenerator>( from: DAAM_V8.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V8.MetadataGenerator>(from: DAAM_V8.metadataStoragePath)!
    }

    pre { percentage >= 0.1 || percentage <= 0.3 }

    execute {
        self.requestGen.acceptDefault(mid: self.mid, metadataGen: self.metadataGen, percentage: self.percentage)
        log("Request Made")
    }
}
