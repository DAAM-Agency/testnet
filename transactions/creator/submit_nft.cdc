// submit_nft.cdc
// Creator uses to submit Metadata

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator     : AuthAccount
    let metadataGen : &DAAM.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    execute {
        self.metadataGen.addMetadata(creator: self.creator, series: series, data: data, thumbnail: thumbnail, file: file)!        
        log("Metadata Submitted")
    }
}
