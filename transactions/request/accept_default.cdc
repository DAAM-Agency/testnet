// accept_default.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64) {
    let creator      : AuthAccount
    let requestGen  : &DAAM_V2.RequestGenerator
    let metadataGen : &DAAM_V2.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.requestGen = self.creator.borrow<&DAAM_V2.RequestGenerator>( from: DAAM_V2.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM_V2.MetadataGenerator>(from: DAAM_V2.metadataStoragePath)!
    }

    execute {
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata)!
        log("Request Made")
    }
}
