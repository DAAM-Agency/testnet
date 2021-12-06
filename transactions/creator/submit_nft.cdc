// submit_nft.cdc
// Creator uses to submit Metadata

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V7          from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator     : AuthAccount
    let metadataGen : &DAAM_V7.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = creator.borrow<&DAAM_V7.MetadataGenerator>(from: DAAM_V7.metadataStoragePath)!
    }

    execute {
        self.metadataGen.addMetadata(creator: self.creator, series: series, data: data, thumbnail: thumbnail, file: file)!        
        log("Metadata Submitted")
    }
}
