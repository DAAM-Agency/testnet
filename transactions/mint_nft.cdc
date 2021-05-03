import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction() {

    // local variable for storing the minter reference
    let minter: &DAAM.NFTMinter
    let address: Address

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&DAAM.NFTMinter>(from: DAAM.minterStorage)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {   
        let metadata = DAAM.Metadata(
        title  : "Title", 
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
        log("Metadata completed")

        // Borrow the recipient's public NFT collection reference
        /*let receiver = getAccount(0xf8d6e0586b0a20c7)
            .getCapability(/public/DAAMVault)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")*/

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(metadata: metadata) // recipient: receiver, 
        log("NFT Minted")
    }
}
