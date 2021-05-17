// transfer.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM_NFT from 0xfd43f9148d4b725d

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(signer: Address, withdrawID: UInt64) {

    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @DAAM_NFT.NFT
	
    prepare(acct: AuthAccount) {

        // Borrow a reference from the stored collection
        let collectionRef = acct.borrow<&DAAM_NFT.Collection>(from: DAAM_NFT.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID) as! @DAAM_NFT.NFT
    }

    execute {        
        let recipient = getAccount(signer)  // Get the recipient's public account object
        // Get the Collection reference for the receiver getting the public capability and borrowing a reference from it
        let receiverCap = recipient.getCapability<&DAAM_NFT.Collection>
            (DAAM_NFT.collectionPublicPath)!
        let receiverRef = receiverCap.borrow()! //as &DAAM_NFT.Collection //{NonFungibleToken.CollectionPublic}
        receiverRef.deposit(token: <- self.transferToken)!  // Deposit the NFT in the receivers collection

        let logmsg = "Transfer: ".concat(recipient.address.toString().concat(" TokenID: ").concat(withdrawID.toString()) )        
        log(logmsg)
    }
}
