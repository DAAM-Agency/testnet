// mint.cdc
// Used for Admin / Agent to mint on behalf in their Creator

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_Mainnet             from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64)
{
    let minterRef : &DAAMDAAM_Mainnet_Mainnet.Minter
    let mid       : UInt64
    let metadataRef : &{DAAM_Mainnet.MetadataGeneratorMint}
    let receiverRef : &{NonFungibleToken.CollectionPublic}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAMDAAM_Mainnet_Mainnet.Minter>(from: DAAM_Mainnet.minterStoragePath)!
        self.mid       = mid

        self.receiverRef  = getAccount(creator)
            .getCapability(DAAM_Mainnet.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()!


        self.metadataRef = getAccount(creator)
            .getCapability(DAAM_Mainnet.metadataPublicPath)
            .borrow<&{DAAM_Mainnet.MetadataGeneratorMint}>()!
    }

    execute {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.deposit(token: <-nft )
        
        log("Minted & Transfered")
    }
}
