// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews    from 0xf8d6e0586b0a20c7
import DAAM_Mainnet             from 0xfd43f9148d4b725d

pub fun compareArray(_ mids: [UInt64], _ features: [UInt64]) {
    for f in features {
        if !mids.contains(f) { panic("MID: ".concat(f.toString().concat(" can not be Featured."))) }
    }
}

transaction(creator: Address, mid: [UInt64], name: String, feature: [UInt64])
{
    let minterRef : &DAAMDAAM_Mainnet_Mainnet.Minter
    let mid       : [UInt64]
    let feature   : [UInt64]
    let name      : String
    let metadataRef  : &{DAAM_Mainnet.MetadataGeneratorMint}
    let collectionRef: &DAAMDAAM_Mainnet_Mainnet.Collection{DAAM_Mainnet.CollectionPublic}
    let agentRef     : &DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}

    prepare(minter: AuthAccount) {
        compareArray(mid, feature)
        self.minterRef = minter.borrow<&DAAMDAAM_Mainnet_Mainnet.Minter>(from: DAAM_Mainnet.minterStoragePath)!
        self.mid       = mid
        self.feature   = feature

        self.collectionRef  = getAccount(creator)
            .getCapability(DAAM_Mainnet.collectionPublicPath)
            .borrow<&DAAMDAAM_Mainnet_Mainnet.Collection{DAAM_Mainnet.CollectionPublic}>()!

        self.metadataRef = getAccount(creator)
            .getCapability(DAAM_Mainnet.metadataPublicPath)
            .borrow<&{DAAM_Mainnet.MetadataGeneratorMint}>()!
        
        self.agentRef = minter.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!

        self.name = name
    }

    execute
    {
        for m in self.mid {
            let minterAccess <- self.minterRef.createMinterAccess(mid: m)
            let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
            let nft <- self.minterRef.mintNFT(metadata: <-metadata)
            self.collectionRef.depositByAgent(token: <-nft, name: self.name, feature: self.feature.contains(m), permission: self.agentRef)
            
            log("Minted & Transfered")
        }
    }
}
 