import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(recipient: Address /* , metadata: DAAM.Metadata*/) {

    // local variable for storing the minter reference
    let minter: &DAAM.NFTMinter

    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&DAAM.NFTMinter>(from: /storage/NFTMinter)
            ?? panic("Could not borrow a reference to the NFT minter")
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

        // Borrow the recipient's public NFT collection referenc
        let receiver = getAccount(recipient).getCapability(/public/DAAMVault)
        let borrow = receiver.borrow<&DAAM.Vault>()?
            //.borrow<&{NonFungibleToken.CollectionPublic}>()// TODO BUG HERE  Could not get receiver reference to the NFT Collection
            //?? panic("Could not get receiver reference to the NFT Collection")
            
        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, metadata: metadata)
    }
}

/*

transaction(recipient: Address) {    
    let adminRef: &DAAM.Admin  // local variable for the admin reference

    prepare(acct: AuthAccount) {       
        self.adminRef = acct.borrow<&DAAM.Admin>(from: /storage/DAAMAdmin)!
    } // borrow a reference to the Admin resource in storage

    execute {
        
        let setRef = self.adminRef.borrowSet(setID: setID)  // Borrow a reference to the specified set
        
        // Mint a new NFT
        //let moment1 <- setRef.mintMoment(playID: playID)

        // get the public account object for the recipient
        //let recipient = getAccount(recipient)

        // get the Collection reference for the receiver
        //let receiverRef = recipient.getCapability(/public/DAAMCollection).borrow<&{DAAM.Collection}>()
            ?? panic("Cannot borrow a reference to the recipient's moment collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-moment1)
    }
} */