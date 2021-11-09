// remove_submission.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM_V4            from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64)
{    
    let creator     : AuthAccount
    let mid         : UInt64
    let metadataGen : &DAAM.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.mid = mid
    }

    execute {
        self.metadataGen.removeMetadata(creator: self.creator, mid: self.mid)        
        log("Metadata Submitted")
    }
}
