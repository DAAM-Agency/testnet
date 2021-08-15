// submit_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V3.V2             from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator: &DAAM_V3.Creator

    prepare(creator: AuthAccount)
    {
        self.creator = creator.borrow<&DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)!
        if creator.borrow<&DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath) == nil {
            let mg <-! self.creator.newMetadataGenerator()     
            creator.save<@DAAM_V3.MetadataGenerator>(<- mg, to: DAAM_V3.metadataStoragePath)
            creator.link<&DAAM_V3.MetadataGenerator>(DAAM_V3.metadataPublicPath, target: DAAM_V3.metadataStoragePath)
        } 
        let metadataGenerator = creator.borrow<&DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)
        metadataGenerator?.addMetadata(series: series, data: data, thumbnail: thumbnail, file: file)!
        
        log("Metadata Submitted")
    }
}
