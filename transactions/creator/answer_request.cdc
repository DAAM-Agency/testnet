// answer_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(answer: Bool, request: UInt8, tokenID: UInt64) {

    // local variable for storing the creatorRef reference
    let creatorRef: &DAAM.Creator
    let creator: AuthAccount
        
    prepare(creator: AuthAccount) {
        self.creator = creator
        // borrow a reference to the creatorRef resource in storage
        self.creatorRef = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)
            ?? panic("Could not borrow a reference to the Creator Storage")
        
        let collection = creator.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow Collection")
        
        let nft <-! collection.withdraw(withdrawID: tokenID) as! @DAAM.NFT
        let nftRef = &nft as &DAAM.NFT
             
        self.creatorRef.answerRequest(creator: self.creator.address, nft: nftRef, answer: answer, request: request)
        collection.deposit(token: <- nft)
        log("Request Answered")
    }
}
