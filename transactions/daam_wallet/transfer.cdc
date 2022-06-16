// transfer.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(signer: Address, withdrawID: UInt64) {

    // The field that will hold the NFT as it is being transferred to the other account
    let transferToken: @NonFungibleToken.NFT
	
    prepare(acct: AuthAccount) {

        // Borrow a reference from the stored collection
<<<<<<< HEAD
        let collectionRef = acct.borrow<&DAAM_V10.Collection{NonFungibleToken.Provider}>(from: DAAM_V10.collectionStoragePath)
=======
        let collectionRef = acct.borrow<&DAAM_V14.Collection{NonFungibleToken.Provider}>(from: DAAM_V14.collectionStoragePath)
>>>>>>> DAAM_V14
            ?? panic("Could not borrow a reference to the owner's collection")

        // Call the withdraw function on the sender's Collection to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {        
        let recipient = getAccount(signer)  // Get the recipient's public account object
        // Get the Collection reference for the receiver getting the public capability and borrowing a reference from it
<<<<<<< HEAD
        let receiverCap = recipient.getCapability<&DAAM_V10.Collection{NonFungibleToken.Receiver}>(DAAM_V10.collectionPublicPath)
        let receiverRef = receiverCap.borrow()! //as &DAAM_V10.Collection //{NonFungibleToken.CollectionPublic}
=======
        let receiverCap = recipient.getCapability<&DAAM_V14.Collection{NonFungibleToken.Receiver}>(DAAM_V14.collectionPublicPath)
        let receiverRef = receiverCap.borrow()! //as &DAAM_V14.Collection //{NonFungibleToken.CollectionPublic}
>>>>>>> DAAM_V14
        receiverRef.deposit(token: <- self.transferToken)  // Deposit the NFT in the receivers collection

        let logmsg = "Transfer: ".concat(recipient.address.toString().concat(" TokenID: ").concat(withdrawID.toString()) )        
        log(logmsg)
    }
}
