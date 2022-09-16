// mint.cdc
// Used for Admin / Agent to mint on behalf in their Creator

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM             from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64)
{
    let minterRef : &DAAM.Minter
    let mid       : UInt64
    let metadataRef : &{DAAM.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.mid       = mid

        self.receiverRef  = getAccount(creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(creator)
            .getCapability(DAAM.metadataPublicPath)
            .borrow<&{DAAM.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")
    }
}
