// mint_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(creator: Address, elm: UInt /* , copyrightStatus: DAAM.CopyrightStatus*/ ) {
    // local variable for storing the minter reference
    let minter  : &DAAM.Creator
    let receiver: &{NonFungibleToken.CollectionPublic}    

    prepare(admin: AuthAccount) {
        // borrow a reference to the admin resource in storage
        self.minter = getAccount(creator)
        .getCapability(DAAM.creatorPublicPath)
        .borrow<&DAAM.Creator>()
            ?? panic("Could not borrow a reference to the NFT minter")
        
        // Borrow the recipient's public collection reference
        self.receiver = getAccount(creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("You don't have a DAAM Collection. Setup an DAAM account first!")
    }

    execute {
        let copyrightStatus = DAAM.CopyrightStatus.VERIFIED  // TODO Remove, for testing only

        // Mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: self.receiver, creator:creator, elm:elm, copyrightStatus:copyrightStatus)
        log("NFT Minted")
    }
}
