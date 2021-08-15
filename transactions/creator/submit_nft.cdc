// submit_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V1             from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{    
    let creator: &DAAM_V1.Creator

    prepare(creator: AuthAccount)
    {
        self.creator = creator.borrow<&DAAM_V1.Creator>(from: DAAM_V1.creatorStoragePath)!
        if creator.borrow<&DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath) == nil {
            let mg <-! self.creator.newMetadataGenerator()     
            creator.save<@DAAM_V1.MetadataGenerator>(<- mg, to: DAAM_V1.metadataStoragePath)
            creator.link<&DAAM_V1.MetadataGenerator>(DAAM_V1.metadataPrivatePath, target: DAAM_V1.metadataStoragePath)
        } 
        let metadataGenerator = creator.borrow<&DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath)
        metadataGenerator?.addMetadata(series: series, data: data, thumbnail: thumbnail, file: file)!
        
        log("Metadata Submitted")
    }
}
