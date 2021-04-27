import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7
import DAAMAdminReceiver from 0xf8d6e0586b0a20c7

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
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(recipient)
            .getCapability(/public/DAAMVault)
            //.borrow<&{DAAMAdminReceiver.Vault}>()
            .borrow<&{NonFungibleToken.CollectionPublic}>()  // TODO BUG HERE  Could not get receiver reference to the NFT Collection
            ?? panic("Could not get receiver reference to the NFT Collection")
            
        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, metadata: metadata)
    }
}
