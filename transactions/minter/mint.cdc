// change_creator_status.cdc
// Used for Admin / minters to change Creator status. True = active, False = frozen

import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V22.V22             from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V22         from 0xa4ad5ea5c0bd2fba
>>>>>>> 586a0096 (updated FUSD Address)

transaction(creator: Address, mid: UInt64) {
    let minterRef : &DAAM_V22.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM_V22.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
<<<<<<< HEAD
        self.minterRef = minter.borrow<&DAAM_V22.Minter>(from: DAAM_V22.V22.minterStoragePath)!
=======
        self.minterRef = minter.borrow<&DAAM_V22.Minter>(from: DAAM_V22.minterStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
        self.creator   = creator
        self.mid       = mid

        self.receiverRef  = getAccount(self.creator)
            .getCapability(DAAM_V22.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
            .getCapability(DAAM_V22.metadataPublicPath)
            .borrow<&{DAAM_V22.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess(mid: mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")
    }
}
