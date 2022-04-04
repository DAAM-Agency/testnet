// submit_all.cdc
// Creator uses to submit Metadata & Approve Rpyalty

import Categories from 0xfd43f9148d4b725d
import DAAM       from 0xfd43f9148d4b725d
transaction(series: UInt64, categories: [String], data: String,  thumbnail: String, file: String, percentage: UFix64)
{    
    //let creator     : AuthAccount
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator

    let series      : UInt64
    let data        : String
    var categories  : [Categories.Category]
    let thumbnail   : String
    let file        : String
    let percentage  : UFix64

    prepare(creator: AuthAccount) {
        //self.creator     = creator
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.requestGen  = creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!

        self.series     = series
        self.data       = data
        self.thumbnail  = thumbnail
        self.file       = file
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
        self.percentage = percentage
    }

    pre { percentage >= 0.1 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(series: self.series, categories: self.categories, data: self.data, thumbnail: self.thumbnail, file: self.file)       
        self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, percentage: self.percentage)

        log("Metadata Submitted: ".concat(mid.toString()).concat(" with a Royalty Percentage: ".concat((self.percentage*100.0).toString()).concat(" Accepted.")))
    }
}
