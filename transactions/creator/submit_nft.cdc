// submit_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creatorRef: &DAAM.Creator

    prepare(creator: AuthAccount)
    {
        self.creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
        if creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath) == nil {
            let mg <-! self.creatorRef.newMetadataGenerator()     
            creator.save<@DAAM.MetadataGenerator>(<- mg, to: DAAM.metadataStoragePath)
            creator.link<&DAAM.MetadataGenerator>(DAAM.metadataPrivatePath, target: DAAM.metadataStoragePath)
        } 
        let metadataGenerator = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        metadataGenerator?.addMetadata(series: series, data: data, thumbnail: thumbnail, file: file)!
        
        log("Metadata Submitted")
    }
}
