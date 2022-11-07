// remove_submission.cdc
// Creator can remove Metadata submission

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM_Mainnet             from 0xfd43f9148d4b725d

transaction(mid: UInt64)
{    
    let creator     : AuthAccount
    let mid         : UInt64
    let metadataGen : &DAAMDAAM_Mainnet_Mainnet.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAMDAAM_Mainnet_Mainnet.MetadataGenerator>(from: DAAM_Mainnet.metadataStoragePath)!
        self.mid = mid
    }

    execute {
        self.metadataGen.removeMetadata(mid: self.mid)        
        log("Metadata Submitted")
    }
}
