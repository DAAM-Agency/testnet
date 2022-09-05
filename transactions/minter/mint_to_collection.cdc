// mint.cdc
// Used for Admin / Agent to mint on behalf in their Creator

import NonFpungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews     from 0xf8d6e0586b0a20c7
import DAAM              from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, collectionIndex: UInt64)
{
    let minterRef : &DAAM.Minter
    let creator   : Address
    let mid       : UInt64
    let metadataRef : &{DAAM.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}
    let collectionIndex: UInt64

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.creator   = creator
        self.mid       = mid
        self.collectionIndex = collectionIndex

        self.receiverRef  = getAccount(self.creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(self.creator)
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
