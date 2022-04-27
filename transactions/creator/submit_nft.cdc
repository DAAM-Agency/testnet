// submit_nft.cdc
// Creator uses to submit Metadata

import Categories from 0xa4ad5ea5c0bd2fba
import DAAM_V10       from 0xa4ad5ea5c0bd2fba
transaction(series: UInt64, categories: [String], data: String,  thumbnail: String, file: String)
{    
    //let creator     : AuthAccount
    let metadataGen : &DAAM_V10.MetadataGenerator
    let series      : UInt64
    let data        : String
    var categories  : [Categories.Category]
    let thumbnail   : String
    let file        : String

    prepare(creator: AuthAccount) {
        //self.creator = creator
        self.metadataGen = creator.borrow<&DAAM_V10.MetadataGenerator>(from: DAAM_V10.metadataStoragePath)!

        self.series     = series
        self.data       = data
        self.thumbnail  = thumbnail
        self.file       = file
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
    }

    execute {
        self.metadataGen.addMetadata(series: self.series, categories: self.categories, data: self.data, thumbnail: self.thumbnail, file: self.file)       
        log("Metadata Submitted")
    }
}
