// submit_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(/*metadata: DAAM.Metadata */) {
    
    prepare(creator: AuthAccount) {
        let metadata = DAAM.Metadata(
            creator  : creator.address,
            series   : 1 as UInt64,
            counter  : 1 as UInt64,            
            data     : "metadata",
            thumbnail: "thumbnail",
            file     : "file"
        )    
        log("Metadata Virtual Input Completed")

        let creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!

        if creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath) == nil {
            let metadataGenerator <-! creatorRef.newMetadataGenerator(metadata: metadata)     
            creator.save<@DAAM.MetadataGenerator>(<- metadataGenerator, to: DAAM.metadataStoragePath)
            creator.link<&DAAM.MetadataGenerator>(DAAM.metadataPrivatePath, target: DAAM.metadataStoragePath)
        } else {
            let metadataGenerator = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
            metadataGenerator?.addMetadata(metadata: metadata)!
        }
        log("NFT Submitted")
    }
}