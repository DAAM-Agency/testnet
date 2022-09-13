// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews    from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, index: UInt64? )
{
    let minterRef : &DAAM.Minter
    let creator   : Address
    let mid       : UInt64
    let index     : UInt64?
    let metadataRef  : &{DAAM.MetadataGeneratorMint}
    let receiverRef  : &{NonFungibleToken.CollectionPublic}
    let collectionRef: &DAAM.Collection

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.creator   = creator
        self.mid       = mid
        self.index     = index

        self.receiverRef  = getAccount(self.creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!

        self.metadataRef = getAccount(self.creator)
            .getCapability(DAAM.metadataPublicPath)
            .borrow<&{DAAM.MetadataGeneratorMint}>()!

        self.collectionRef = getAccount(self.creator)
            .getCapability(DAAM.CollectionPublicPath)
            .borrow<&DAAM.Collection{DAAM.CollectionPublic}>()!
    }

    execute
    {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        //self.receiverRef.deposit(token: <-nft)
        self.receiverRef.depositByAgent(token: <-nft, index: self.index, permission: self.agent)
        
        log("Minted & Transfered")
    }
}
