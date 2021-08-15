// submit_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V2.V2             from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator: &DAAM_V2.Creator

    prepare(creator: AuthAccount)
    {
        self.creator = creator.borrow<&DAAM_V2.Creator>(from: DAAM_V2.creatorStoragePath)!
        if creator.borrow<&DAAM_V2.MetadataGenerator>(from: DAAM_V2.metadataStoragePath) == nil {
            let mg <-! self.creator.newMetadataGenerator()     
            creator.save<@DAAM_V2.MetadataGenerator>(<- mg, to: DAAM_V2.metadataStoragePath)
            creator.link<&DAAM_V2.MetadataGenerator>(DAAM_V2.metadataPublicPath, target: DAAM_V2.metadataStoragePath)
        } 
        let metadataGenerator = creator.borrow<&DAAM_V2.MetadataGenerator>(from: DAAM_V2.metadataStoragePath)
        metadataGenerator?.addMetadata(series: series, data: data, thumbnail: thumbnail, file: file)!
        
        log("Metadata Submitted")
    }
}
