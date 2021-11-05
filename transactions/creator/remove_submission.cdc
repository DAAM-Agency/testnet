// remove_submission.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM_V4            from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64)
{    
    let creator     : &DAAM.Creator
    let metadataGen : &DAAM.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    execute {
        self.metadataGen.removeMetadata(mid: mid)        
        log("Metadata Submitted")
    }
}
