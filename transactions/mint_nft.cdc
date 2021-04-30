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
        
        let minter <- DAAM.createMinter()
        minter.mintNFT(metadata: metadata)
        destroy minter
    }

}