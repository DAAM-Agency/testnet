// submit_all.cdc
// Creator uses to submit Metadata
// Creator selects Royality between 10% to 30%

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(series: UInt64, data: String, thumbnail: String, file: String, percentage: UFix64)
{    
    let creator     : AuthAccount
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator     = creator
        self.requestGen  = self.creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    pre {
        percentage >= 0.1 || percentage <= 0.3 : "Percentages must be inbetween 10% to 30%."
    }

    execute {
        let mid = self.metadataGen.addMetadata(creator: self.creator, series: series, data: data, thumbnail: thumbnail, file: file)!
        let metadata = self.metadataGen.getMetadataRef(creator.owner, mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata, percentage: percentage)
        log("Metadata & Royality Submitted")
    }
}

