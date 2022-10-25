// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews    from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, name: String, feature: Bool)
{
    let minterRef : &DAAM.Minter
    let mid       : UInt64
    let name      : String
    let feature   : Bool
    let metadataRef  : &{DAAM.MetadataGeneratorMint}
    let collectionRef: &DAAM.Collection{DAAM.CollectionPublic}
    let agentRef     : &DAAM.Admin{DAAM.Agent}

    prepare(minter: AuthAccount) {
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.mid       = mid
        self.name      = name
        self.feature   = feature

        self.collectionRef = getAccount(creator)
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
        self.collectionRef.depositByAgent(token: <-nft, name: self.name, feature: self.feature, permission: self.agentRef)
        
        log("Minted & Transfered")
    }
}
