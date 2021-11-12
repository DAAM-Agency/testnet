// remove_submission.cdc
// Creator can remove Metadata submission

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V5             from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64)
{    
    let creator     : AuthAccount
    let mid         : UInt64
    let metadataGen : &DAAM_V5.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)!
        self.mid = mid
    }

    execute {
        self.metadataGen.removeMetadata(creator: self.creator, mid: self.mid)        
        log("Metadata Submitted")
    }
}
