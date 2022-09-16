// mint.cdc
// Used for Admin / Agent to mint on behalf in their Creator

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V23         from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64) {
    let minterRef : &DAAM_V23.Minter
    let mid       : UInt64
    let metadataRef : &{DAAM_V23.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM_V23.Minter>(from: DAAM_V23.minterStoragePath)!
        self.mid       = mid

        self.receiverRef  = getAccount(self.creator)
            .getCapability(DAAM_V23.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
            .getCapability(DAAM_V23.metadataPublicPath)
            .borrow<&{DAAM_V23.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")
    }
}
