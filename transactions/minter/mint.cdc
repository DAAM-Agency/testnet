// change_creator_status.cdc
// Used for Admin / minters to change Creator status. True = active, False = frozen

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V21.V21             from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, receiver: Address) {
    let minterRef : &DAAM_V21.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM_V21.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM_V21.Minter>(from: DAAM_V21.V21.minterStoragePath)!
        self.creator   = creator
        self.mid       = mid

        self.receiverRef  = getAccount(receiver)
            .getCapability(DAAM_V21.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
            .getCapability(DAAM_V21.metadataPublicPath)
            .borrow<&{DAAM_V21.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess()
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess, mid: self.mid)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")   
    }
}
