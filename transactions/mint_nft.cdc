// Transaction2.cdc

import DAAM from 0xf8d6e0586b0a20c7 

// This transaction allows the Minter account to mint an NFT
// and deposit it into its collection.

transaction {

    // The reference to the collection that will be receiving the NFT
    let receiverRef: &{DAAM.DAAMReceiver}

    // The reference to the Minter resource stored in account storage
    let minterRef: &DAAM.DAAMMinter

    prepare(acct: AuthAccount) {
        // Get the owner's collection capability and borrow a reference
        self.receiverRef = acct.getCapability<&{DAAM.DAAMReceiver}>(/public/DAAMReceiver)
            .borrow()
            ?? panic("Could not borrow receiver reference")
        
        // Borrow a capability for the DAAMMinter in storage
        self.minterRef = acct.borrow<&DAAM.DAAMMinter>(from: /storage/DAAMMinter)
            ?? panic("could not borrow minter reference")
    }

    execute {
        // Use the minter reference to mint an NFT, which deposits
        // the NFT into the collection that is sent as a parameter.
        let newNFT <- self.minterRef.mintNFT()

        self.receiverRef.deposit(token: <-newNFT)

        log("NFT Minted and deposited to Account 2's Collection")
    }
}

