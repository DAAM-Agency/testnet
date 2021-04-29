//import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7

// This transaction is what an admin would use to mint a single new moment
// and deposit it in a user's collection

// Parameters:
//
// setID: the ID of a set containing the target play
// playID: the ID of a play from which a new moment is minted
// recipientAddr: the Flow address of the account receiving the newly minted moment

transaction() {
    // local variable for the admin reference
    let adminRef: &DAAM.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&DAAM.Admin>(from: /storage/DAAMAdmin)!
    }

    execute {
        //let mainVault = 0 as UInt64
        // Borrow a reference to the specified vault
        //let vaultRef = self.adminRef.borrowVault(id: mainVault)

        // Mint a new NFT
        self.adminRef.addNFT()

        // get the public account object for the recipient
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        //let receiverRef = recipient.getCapability(/public/MomentCollection).borrow<&{TopShot.MomentCollectionPublic}>()
            //?? panic("Cannot borrow a reference to the recipient's moment collection")

        // deposit the NFT in the receivers collection
        //receiverRef.deposit(token: <-moment1)
    }
}
