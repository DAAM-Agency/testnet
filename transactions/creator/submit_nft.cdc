// submit_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(/*metadata: DAAM.Metadata */) {
    var saved_metadata: &DAAM.Metadata
    let creator: AuthAccount
    
    prepare(creator: AuthAccount) {
        let metadata = DAAM.Metadata(
                creator: self.creatorAddress,
                metadata : "metadata",
                thumbnail: "thumbnail",
                file     : "file"
        )    
        log("Metadata Virtual Input Completed")
        self.creator = creator
        self.saved_metadata = creator.borrow<&DAAM.Metadata>(from: DAAM.submitPrivatePath)!
    }

    execute {
        // borrow a reference to the Creator resource in storage
        if self.saved_metadata == nil {
            self.creator.save<DAAM.Metadata>(metadata, to: DAAM.submitStoragePath)
            self.creator.link<&DAAM.Metadata>(DAAM.submitPrivatePath, to: DAAM.submitStoragePath)
        }
        self.saved_metadata.append(metadata)
         
        log("NFT Submitted")
        emit DAAM.SubmitNFT(creator: self.creator)
    }
}
