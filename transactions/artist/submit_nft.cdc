// submit_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(/*metadata: DAAM.Metadata */) {
    // local variable for storing the artist reference
    let artistRef    : &DAAM.Artist
    let artistAddress: Address
    
    prepare(artist: AuthAccount) {
        // borrow a reference to the Artist resource in storage
        self.artistRef = artist.borrow<&DAAM.Artist>(from: DAAM.artistStoragePath)
            ?? panic("Could not borrow a reference to the NFT artist")
        self.artistAddress = artist.address 
    }

    execute {
        let metadata = DAAM.Metadata(
                creator: self.artistAddress,
                metadata : "metadata",
                thumbnail: "thumbnail",
                file     : "file"
        )    
        log("Metadata Virtual Input Completed")        

        // Submit the NFT and deposit for review
        self.artistRef.submitNFT(artist: self.artistAddress, metadata: metadata)
        log("NFT Submitted")
    }
}
