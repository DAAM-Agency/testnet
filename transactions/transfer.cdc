// transfer.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM_NFT from 0xfd43f9148d4b725d

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(recipient: Address, withdrawID: UInt64) {

    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @DAAM_NFT.NFT
	
    prepare(acct: AuthAccount) {

        // Borrow a reference from the stored collection
        let collectionRef = acct.borrow<&DAAM_NFT.Collection{NonFungibleToken.Provider}>(from: DAAM_NFT.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID) as! @DAAM_NFT.NFT
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(recipient)

        // Get the Collection reference for the receiver
        // getting the public capability and borrowing a reference from it
        let receiverRef = recipient.getCapability<&DAAM_NFT.Collection{NonFungibleToken.CollectionPublic}>
            (DAAM_NFT.collectionPublicPath)
            .borrow()
            ?? panic("Could not borrow receiver reference")

        // Deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)

        log("NFT ID 1 transferred from account 2 to account 1")
    }
}
