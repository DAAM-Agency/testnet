// remove_submission.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

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
