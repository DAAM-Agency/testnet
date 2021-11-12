// accept_default.cdc
// Creator selects Royality between 10% to 30%

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64) {
    let creator      : AuthAccount
    let requestGen  : &DAAM_V5.RequestGenerator
    let metadataGen : &DAAM_V5.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.requestGen = self.creator.borrow<&DAAM_V5.RequestGenerator>( from: DAAM_V5.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)!
    }

    pre { percentage >= 0.1 || percentage <= 0.3 }

    execute {
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata, percentage: percentage)
        log("Request Made")
    }
}
