// submit_all.cdc
// Creator uses to submit Metadata & Approve Rpyalty

import Categories    from 0xfd43f9148d4b725d
import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

transaction(name: String, max: UInt64, categories: [String], editions: MetadataViews.Editions?, description: String,  
    thumbnail: {MetadataViews.File}, file: MetadataViews.Media, percentage: UFix64)
{    
    //let creator     : AuthAccount
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator

    let name        : String
    let max         : UInt64
    var categories  : [Categories.Category]
    let editions    : MetadataViews.Editions?
    let description : String
    let thumbnail   : {MetadataViews.File}
    let file        : MetadataViews.Media
    let percentage  : UFix64

    prepare(creator: AuthAccount) {
        //self.creator     = creator
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.requestGen  = creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!

        self.name        = name
        self.max         = max
        self.description = description
        self.editions    = editions
        self.thumbnail   = thumbnail
        self.file        = file
        self.categories  = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
        self.percentage = percentage
    }

    pre { percentage >= 0.1 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(name: self.name, max: self.max, categories: self.categories, editions: self.editions,
        description: self.description, thumbnail: self.thumbnail, file: self.file)

        self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, percentage: self.percentage)

        log("Metadata Submitted: ".concat(mid.toString()))
    }
}
