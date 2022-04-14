// change_creator_status.cdc
// Used for Admin / minters to change Creator status. True = active, False = frozen

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, receiver: Address) {
    let minterRef : &DAAM_V8.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM_V8.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM_V8.Minter>(from: DAAM_V8.minterStoragePath)!
        self.creator   = creator
        self.mid       = mid

        self.receiverRef  = getAccount(receiver)
            .getCapability(DAAM_V8.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
            .getCapability(DAAM_V8.metadataPublicPath)
            .borrow<&{DAAM_V8.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess()
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess, mid: self.mid)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")   
    }
}
