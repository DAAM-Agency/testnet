import NonFungibleToken from 0xf8d6e0586b0a20c7
import ExampleNFT from 0xf8d6e0586b0a20c7

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(metadata: ExampleNFT.Metadata) {
    let minter: &ExampleNFT.NFTMinter

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.minterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    } 

    execute {   
        /*let metadata = ExampleNFT.Metadata(
        title  : "Title", 
        format : "format",
        file   : "file",     
        creator: self.address,  //&Profile
        about  : "about",
        physical: "False",
        series : "series",
        agency : "Agency",
        thumbnail_format: "thumbnail format",
        thumbnail: "thumbnail"
        )     
        log("Metadata completed")*/

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(metadata: metadata) //  
        log("NFT Minted")
    }
}
