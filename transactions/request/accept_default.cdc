// accept_default.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64) {
    let creator      : AuthAccount
    let requestGen  : &DAAM_V1.RequestGenerator
    let metadataGen : &DAAM_V1.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.requestGen = self.creator.borrow<&DAAM_V1.RequestGenerator>( from: DAAM_V1.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath)!
    }

    execute {
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata)!
        log("Request Made")
    }
}
