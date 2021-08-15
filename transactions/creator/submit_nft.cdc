// submit_nft.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator: &DAAM.Creator

    prepare(creator: AuthAccount)
    {
        self.creator = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
        if creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath) == nil {
            let mg <-! self.creator.newMetadataGenerator()     
            creator.save<@DAAM.MetadataGenerator>(<- mg, to: DAAM.metadataStoragePath)
            creator.link<&DAAM.MetadataGenerator>(DAAM.metadataPublicPath, target: DAAM.metadataStoragePath)
        } 
        let metadataGenerator = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        metadataGenerator?.addMetadata(series: series, data: data, thumbnail: thumbnail, file: file)!
        
        log("Metadata Submitted")
    }
}
