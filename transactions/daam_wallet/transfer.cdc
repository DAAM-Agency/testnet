// transfer.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(to: Address, id: UInt64) {

    // The field that will hold the NFT as it is being transferred to the other account
    //let transferToken: @NonFungibleToken.NFT
    //let receiverRef:  &{NonFungibleToken.Receiver}
	
    prepare(acct: AuthAccount) {

        // Borrow a reference from the stored collection
        let collectionRef = acct.borrow<&{NonFungibleToken.Provider}>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // Call the withdraw function on the sender's Collection to move the NFT out of the collection
        //self.transferToken <- collectionRef.withdraw(withdrawID: id)
        let receiverCap = getAccount(to).getCapability<&{NonFungibleToken.Receiver}>(DAAM.collectionPublicPath)
        log(receiverCap)
        //self.receiverRef = receiverCap.borrow()! 
    }

    execute {        
        // Get the Collection reference for the receiver getting the public capability and borrowing a reference from it       
        //self.receiverRef.deposit(token: <- self.transferToken)  // Deposit the NFT in the receivers collection

        let logmsg = "Transfer: ".concat(to.toString().concat(" TokenID: ").concat(id.toString()) )        
        log(logmsg)
    }
}
