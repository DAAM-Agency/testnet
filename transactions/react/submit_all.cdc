// submit_all.cdc
// Creator uses to submit Metadata
// Creator selects Royality between 10% to 30%

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V7          from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String, percentage: UFix64)
{    
    let creator     : AuthAccount
    let requestGen  : &DAAM_V7.RequestGenerator
    let metadataGen : &DAAM_V7.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.requestGen = self.creator.borrow<&DAAM_V7.RequestGenerator>( from: DAAM_V7.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM_V7.MetadataGenerator>(from: DAAM_V7.metadataStoragePath)!
    }

    pre {
        percentage >= 0.1 || percentage <= 0.3 : "Percentages must be inbetween 10% to 30%."
    }

    execute {
        let mid = self.metadataGen.addMetadata(creator: self.creator, series: series, data: data, thumbnail: thumbnail, file: file)!
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata, percentage: percentage)
        log("Metadata & Royality Submitted")
    }
}

