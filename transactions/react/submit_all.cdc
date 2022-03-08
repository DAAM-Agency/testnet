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

    let series     : UInt64
    let data       : String
    let thumbnail  : String
    let file       : String
    let percentage : UFix64

    prepare(creator: AuthAccount) {
        self.creator     = creator
        self.requestGen  = self.creator.borrow<&DAAM_V7.RequestGenerator>( from: DAAM_V7.requestStoragePath)!
        self.metadataGen = self.creator.borrow<&DAAM_V7.MetadataGenerator>(from: DAAM_V7.metadataStoragePath)!

        self.series      = series
        self.data        = data
        self.thumbnail   = thumbnail
        self.file        = file
        self.percentrage = percentage
    }

    pre {
        percentage >= 0.1 || percentage <= 0.3 : "Percentages must be inbetween 10% to 30%."
    }

    execute {
        let mid = self.metadataGen.addMetadata(creator: self.creator, series: self.series, data: self.data, thumbnail: self.thumbnail, file: self.file)!
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata, percentage: self.percentage)
        
        log("Metadata & Royality Submitted")
    }
}

