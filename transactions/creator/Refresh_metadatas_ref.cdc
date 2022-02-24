// refresh_metadatas_ref.cdc
// Get Creators' MIDs

// Tools used for debugging

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction()
{    
    let creator     : AuthAccount
    let metadataGen : &DAAM.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator
        self.metadataGen = self.creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    execute {
        log(self.metadataGen.refreshMetadatasRef(creator))
    }
}
