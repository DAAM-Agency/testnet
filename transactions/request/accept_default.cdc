// accept_default.cdc
// Creator selects Royalty between 10% to 30%

import DAAM_V11 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64) {
    let mid         : UInt64
    let percentage  : UFix64
    let requestGen  : &DAAM_V11.RequestGenerator
    let metadataGen : &DAAM_V11.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.mid     = mid
        self.percentage  = percentage
        self.requestGen  = creator.borrow<&DAAM_V11.RequestGenerator>( from: DAAM_V11.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V11.MetadataGenerator>(from: DAAM_V11.metadataStoragePath)!
    }

    pre { percentage >= 0.01 || percentage <= 0.3 }

    execute {
        self.requestGen.acceptDefault(mid: self.mid, metadataGen: self.metadataGen, percentage: self.percentage)
        log("Request Made")
    }
}
