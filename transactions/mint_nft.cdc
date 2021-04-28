import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7

// This transaction allows the Minter account to mint an NFT and deposit it into its collection.

transaction {

    // The reference to the collection that will be receiving the NFT
    let receiverRef: &{DAAM.NFTReceiver}

    // The reference to the Minter resource stored in account storage
    let minterRef: &DAAM.NFTMinter

    prepare(acct: AuthAccount) {
        // Get the owner's collection capability and borrow a reference
        self.receiverRef = acct.getCapability<&{DAAM.NFTReceiver}>(/public/NFTReceiver)
            .borrow()
            ?? panic("Could not borrow receiver reference")
        
        // Borrow a capability for the NFTMinter in storage
        self.minterRef = acct.borrow<&DAAM.NFTMinter>(from: /storage/NFTMinter)
            ?? panic("could not borrow minter reference")
    }

    execute {
        let metadata = DAAM.Metadata( 
        title: "Title", 
        format : "format",
        file   : "file",     
        creator: "creator",        
        about  : "about",
        physical: "False",
        series : "series",
        agency : "Agency",
        thumbnail_format: "thumbnail format",
        thumbnail: "thumbnail"
        )

        // Use the minter reference to mint an NFT, which deposits
        // the NFT into the collection that is sent as a parameter.
        let newNFT <- self.minterRef.mintNFT()

        self.receiverRef.deposit(token: <-newNFT)

        log("NFT Minted and deposited to Account 2's Collection")
    }
}
