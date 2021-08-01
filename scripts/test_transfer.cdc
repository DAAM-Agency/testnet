// test_transer.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM from 0xfd43f9148d4b725d

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(signer: Address, withdrawID: UInt64) {

    // The field that will hold the NFT as it is being
    // transferred to the other account
    //let transferToken: @DAAM.NFT
	
    prepare(acct: AuthAccount) {

        // Borrow a reference from the stored collection
        let collectionRef = getAccount(signer).getCapability<&DAAM.Collection>(DAAM.collectionPublicPath).borrow()
            ?? panic("Could not borrow a reference to the owner's collection")

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        let transferToken <- collectionRef.withdraw(withdrawID: withdrawID) as! @DAAM.NFT
       
        //let recipient = acct.borrow // Get the recipient's public account object
        // Get the Collection reference for the receiver getting the public capability and borrowing a reference from it
        let receiverRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)!
        //let receiverRef = receiverCap.borrow()! //as &DAAM.Collection //{NonFungibleToken.CollectionPublic}
        receiverRef.deposit(token: <- transferToken)  // Deposit the NFT in the receivers collection

        //let logmsg = "Transfer: ".concat(recipient.address.toString().concat(" TokenID: ").concat(withdrawID.toString()) )        
        log("END")
    }
}
