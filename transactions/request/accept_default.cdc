// accept_default.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64) {
    let creator      : AuthAccount
    let requestGen  : &DAAM_V3.RequestGenerator
    let metadataGen : &DAAM_V3.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.requestGen = self.creator.borrow<&DAAM_V3.RequestGenerator>( from: DAAM_V3.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)!
    }

    execute {
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata, percentage: percentage)
        log("Request Made")
    }
}
