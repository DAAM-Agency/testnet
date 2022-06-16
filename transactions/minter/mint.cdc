// change_creator_status.cdc
// Used for Admin / minters to change Creator status. True = active, False = frozen

<<<<<<< HEAD
import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, receiver: Address) {
    let minterRef : &DAAM_V10.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM_V10.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM_V10.Minter>(from: DAAM_V10.minterStoragePath)!
=======
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V14             from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, receiver: Address) {
    let minterRef : &DAAM_V14.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM_V14.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM_V14.Minter>(from: DAAM_V14.minterStoragePath)!
>>>>>>> DAAM_V14
        self.creator   = creator
        self.mid       = mid

        self.receiverRef  = getAccount(receiver)
<<<<<<< HEAD
            .getCapability(DAAM_V10.collectionPublicPath)
=======
            .getCapability(DAAM_V14.collectionPublicPath)
>>>>>>> DAAM_V14
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
<<<<<<< HEAD
            .getCapability(DAAM_V10.metadataPublicPath)
            .borrow<&{DAAM_V10.MetadataGeneratorMint}>()!
=======
            .getCapability(DAAM_V14.metadataPublicPath)
            .borrow<&{DAAM_V14.MetadataGeneratorMint}>()!
>>>>>>> DAAM_V14
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess()
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess, mid: self.mid)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")   
    }
}
