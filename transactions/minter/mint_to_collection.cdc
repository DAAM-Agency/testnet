// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V23             from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, index: Int?, feature: Bool)
{
    let minterRef : &DAAM.Minter
    let mid       : UInt64
    let index     : Int?
    let feature   : Bool
    let metadataRef  : &{DAAM.MetadataGeneratorMint}
    let collectionRef  : &DAAM.Collection{DAAM.CollectionPublic}
    let agentRef     : &DAAM.Admin{DAAM.Agent}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM_V23.minterStoragePath)!
        self.mid       = mid
        self.index     = index
        self.feature   = feature

        self.collectionRef  = getAccount(creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&DAAM.Collection{DAAM.CollectionPublic}>()!

        self.metadataRef = getAccount(creator)
            .getCapability(DAAM.metadataPublicPath)
            .borrow<&{DAAM.MetadataGeneratorMint}>()!
        
        self.agentRef = minter.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM_V23.adminStoragePath)!
    }

    execute
    {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.collectionRef.depositByAgent(token: <-nft, index: self.index!, feature: self.feature, permission: self.agentRef)
        
        log("Minted & Transfered")
    }
}
