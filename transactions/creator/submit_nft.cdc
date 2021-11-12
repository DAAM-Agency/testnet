// submit_nft.cdc
// Creator uses to submit Metadata

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V5             from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator     : AuthAccount
    let metadataGen : &DAAM_V5.MetadataGenerator

    prepare(creator: AuthAccount) {
        //self.creator = creator.borrow<&DAAM_V5.Creator>(from: DAAM_V5.creatorStoragePath)!
        self.creator = creator
        self.metadataGen = creator.borrow<&DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)!
    }

    execute {
        self.metadataGen.addMetadata(creator: self.creator, series: series, data: data, thumbnail: thumbnail, file: file)!        
        log("Metadata Submitted")
    }
}
