// submit_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V3          from 0xa4ad5ea5c0bd2fba

transaction(series: UInt64, data: String, thumbnail: String, file: String)
{
	let creator     : &DAAM_V3.Creator
    let metadataGen : &DAAM_V3.MetadataGenerator

    prepare(creator: AuthAccount) {
        self.creator = creator.borrow<&DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)!
    }

    execute {
        self.metadataGen.addMetadata(series: series, data: data, thumbnail: thumbnail, file: file)!        
        log("Metadata Submitted")
    }
}
