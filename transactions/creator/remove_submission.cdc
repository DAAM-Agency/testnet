// remove_submission.cdc
// Creator can remove Metadata submission

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V11             from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64)
{    
    let creator     : AuthAccount
    let mid         : UInt64
    let metadataGen : &DAAM_V11.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM_V11.MetadataGenerator>(from: DAAM_V11.metadataStoragePath)!
        self.mid = mid
    }

    execute {
        self.metadataGen.removeMetadata(mid: self.mid)        
        log("Metadata Submitted")
    }
}
