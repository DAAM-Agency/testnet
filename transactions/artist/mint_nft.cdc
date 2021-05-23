import NonFungibleToken from 0x120e725050340cab
import DAAM from 0xfd43f9148d4b725d

// This script uses the Artist resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/Artist

transaction() {

    // local variable for storing the minter reference
    let minter: &DAAM.Artist
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {

        // borrow a reference to the Artist resource in storage
        self.minter = signer.borrow<&DAAM.Artist>(from: DAAM.artistStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
        self.signer = signer    
    }

    execute {
        let metadata = DAAM.Metadata(
                creator: self.signer.address,
                metadata : "metadata",
                thumbnail: "thumbnail",
                file     : "file"
        )    
        log("Metadata completed")

        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(self.signer.address)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("You don't have a DAAM Collection. Setup an DAAM account first!")
        //let receiver = self.signer.address
        

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, metadata: metadata)
        log("NFT Minted")
    }
}
