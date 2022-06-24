// remove_submission.cdc
// Creator can remove Metadata submission

import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V14             from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V15             from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(mid: UInt64)
{    
    let creator     : AuthAccount
    let mid         : UInt64
<<<<<<< HEAD
    let metadataGen : &DAAM_V14.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM_V14.MetadataGenerator>(from: DAAM_V14.metadataStoragePath)!
=======
    let metadataGen : &DAAM_V15.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM_V15.MetadataGenerator>(from: DAAM_V15.metadataStoragePath)!
>>>>>>> DAAM_V15
        self.mid = mid
    }

    execute {
        self.metadataGen.removeMetadata(mid: self.mid)        
        log("Metadata Submitted")
    }
}
