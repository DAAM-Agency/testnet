// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM             from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, index: Int?, feature: Bool)
{
    let minterRef : &DAAM.Minter
    let mid       : UInt64
    let index     : Int?
    let feature   : Bool
    let metadataRef  : &{DAAM.MetadataGeneratorMint}
    let receiverRef  : &DAAM.Collection{DAAM.CollectionPublic}
    let agentRef     : &DAAM.Admin{DAAM.Agent}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.mid       = mid
        self.index     = index
        self.feature   = feature

        self.receiverRef  = getAccount(creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&DAAM.Collection{DAAM.CollectionPublic}>()!

        self.metadataRef = getAccount(creator)
            .getCapability(DAAM.metadataPublicPath)
            .borrow<&{DAAM.MetadataGeneratorMint}>()!
        
        self.agentRef = minter.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
    }

    execute
    {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.receiverRef.depositByAgent(token: <-nft, index: self.index!, feature: self.feature, permission: self.agentRef)
        
        log("Minted & Transfered")
    }
}
