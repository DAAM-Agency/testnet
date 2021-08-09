// submit_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM             from 0x51e2c02e69b53477

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
