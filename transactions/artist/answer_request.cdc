// answer_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(answer: Bool, request: String, tokenID: UInt64) {

    // local variable for storing the artistRef reference
    let artistRef: &DAAM.Artist
    let artist: AuthAccount
        
    prepare(artist: AuthAccount) {
        self.artist = artist
        // borrow a reference to the artistRef resource in storage
        self.artistRef = artist.borrow<&DAAM.Artist>(from: DAAM.artistStoragePath)
            ?? panic("Could not borrow a reference to the Artist Storage")
        
        let collection = artist.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow Collection")
        
        let nft <-! collection.withdraw(withdrawID: tokenID) as! @DAAM.NFT
        let nftRef = &nft as &DAAM.NFT
             
        self.artistRef.answerRequest(artist: self.artist.address, nft: nftRef, answer: answer, request: request)
        collection.deposit(token: <- nft)
        log("Request Answered")
    }
}
