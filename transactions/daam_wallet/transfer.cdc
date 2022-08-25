// transfer.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V22 from 0xa4ad5ea5c0bd2fba

/// This transaction is for transferring and NFT from
/// one account to another
transaction(recipient: Address, withdrawID: UInt64) {

    /// Reference to the withdrawer's collection
    let withdrawRef: &DAAM_V22.Collection

    /// Reference of the collection to deposit the NFT to
    let depositRef: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer
<<<<<<< HEAD
            .borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath)
=======
            .borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath)
>>>>>>> 586a0096 (updated FUSD Address)
            ?? panic("Account does not store an object at the specified path")

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a public reference to the receivers collection
        self.depositRef = recipient
            .getCapability(DAAM_V22.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

    }

    execute {

        // withdraw the NFT from the owner's collection
        let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        self.depositRef.deposit(token: <-nft)

        let logmsg = "Transfer: ".concat(recipient.toString().concat(" TokenID: ").concat(withdrawID.toString()) )        
        log(logmsg)
    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
        self.depositRef.getIDs().contains(withdrawID): "The reciever should now own the NFT"
    }
}
