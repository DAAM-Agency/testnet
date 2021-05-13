import NonFungibleToken from 0x120e725050340cab
import MarketPalace from 0x045a1763c93006ca

// This script uses the Artist resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/Artist

transaction() {

    // local variable for storing the minter reference
    let minter: &MarketPalace.Artist
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {

        // borrow a reference to the Artist resource in storage
        self.minter = signer.borrow<&MarketPalace.Artist>(from: MarketPalace.artistStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
        self.signer = signer    
    }

    execute {
        let metadata = MarketPalace.Metadata(
                title:"Title",
                creator: self.signer.address,
                series: [],
                physical: false,
                agency: "agency",
                about: {"text": "about"},
                thumbnail: {"text":"thumbnail"},
                file: {"text":"file"}
        )    
        log("Metadata completed")

        // Borrow the recipient's public NFT collection reference
        /*let receiver = getAccount(self.signer.address)
            .getCapability(MarketPalace.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("You don't have a D.A.A.M Collection. Setup an D.A.A.M account first!")*/
        let receiver = self.signer.address
        

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, metadata: metadata
        )
        log("NFT Minted")
    }
}
