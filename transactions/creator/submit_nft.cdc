// submit_nft.cdc
// Creator uses to submit Metadata

import Categories from 0xfd43f9148d4b725d
import DAAM       from 0xfd43f9148d4b725d
transaction(series: UInt64, categories: [String], data: String,  thumbnail: String, file: String)
{    
    //let creator     : AuthAccount
    let metadataGen : &DAAM.MetadataGenerator
    let series      : UInt64
    let data        : String
    var categories  : [Categories.Category]
    let thumbnail   : String
    let file        : String

    prepare(creator: AuthAccount) {
        //self.creator = creator
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!

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
