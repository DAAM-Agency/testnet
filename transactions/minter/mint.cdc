// change_creator_status.cdc
// Used for Admin / minters to change Creator status. True = active, False = frozen

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, receiver: Address) {
    let minterRef : &DAAM.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.creator   = creator
        self.mid       = mid

        self.receiverRef  = getAccount(receiver)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
            .getCapability(DAAM.metadataPublicPath)
            .borrow<&{DAAM.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess()
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess, mid: self.mid)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")   
    }
}
