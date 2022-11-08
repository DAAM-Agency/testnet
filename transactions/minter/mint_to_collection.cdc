// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_Mainnet             from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, name: String, feature: Bool)
{
    let minterRef : &DAAM_Mainnet.Minter
    let mid       : UInt64
    let name      : String
    let feature   : Bool
    let metadataRef  : &{DAAM_Mainnet.MetadataGeneratorMint}
    let collectionRef: &DAAM_Mainnet.Collection{DAAM_Mainnet.CollectionPublic}
    let agentRef     : &DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM_Mainnet.Minter>(from: DAAM_Mainnet.minterStoragePath)!
        self.mid       = mid
        self.name      = name
        self.feature   = feature

        self.collectionRef = getAccount(creator)
            .getCapability(DAAM_Mainnet.collectionPublicPath)
            .borrow<&DAAM_Mainnet.Collection{DAAM_Mainnet.CollectionPublic}>()!

        self.metadataRef = getAccount(creator)
            .getCapability(DAAM_Mainnet.metadataPublicPath)
            .borrow<&{DAAM_Mainnet.MetadataGeneratorMint}>()!
        
        self.agentRef = minter.borrow<&DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!
    }

    execute
    {
        let minterAccess <- self.minterRef.createMinterAccess(mid: self.mid)
        let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
        let nft <- self.minterRef.mintNFT(metadata: <-metadata)
        self.collectionRef.depositByAgent(token: <-nft, name: self.name, feature: self.feature, permission: self.agentRef)
        
        log("Minted & Transfered")
    }
}
