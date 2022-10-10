// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V23      from 0xa4ad5ea5c0bd2fba

pub fun compareArray(_ mids: [UInt64], _ features: [UInt64]) {
    for f in features {
        if !mids.contains(f) { panic("MID: ".concat(f.toString().concat(" can not be Featured."))) }
    }
}

transaction(creator: Address, mid: [UInt64], name: String, feature: [UInt64])
{
    let minterRef : &DAAM_V23.Minter
    let mid       : [UInt64]
    let feature   : [UInt64]
    let index     : Int?
    let metadataRef  : &{DAAM_V23.MetadataGeneratorMint}
    let collectionRef: &DAAM_V23.Collection{DAAM_V23.CollectionPublic}
    let agentRef     : &DAAM_V23.Admin{DAAM_V23.Agent}

    prepare(minter: AuthAccount) {
        compareArray(mid, feature)
        self.minterRef = minter.borrow<&DAAM_V23.Minter>(from: DAAM_V23.minterStoragePath)!
        self.mid       = mid
        self.feature   = feature

        self.collectionRef  = getAccount(creator)
            .getCapability(DAAM_V23.collectionPublicPath)
            .borrow<&DAAM_V23.Collection{DAAM_V23.CollectionPublic}>()!

        self.metadataRef = getAccount(creator)
            .getCapability(DAAM_V23.metadataPublicPath)
            .borrow<&{DAAM_V23.MetadataGeneratorMint}>()!
        
        self.agentRef = minter.borrow<&DAAM_V23.Admin{DAAM_V23.Agent}>(from: DAAM_V23.adminStoragePath)!

        let list = self.collectionRef.getCollection()
        var counter = 0
        var elm_found = false
        for elm in list {
            if list[counter].display.name == name {
                elm_found = true
                break
            }
            counter = counter + 1
        }
        self.index = elm_found ? counter : nil
    }

    execute
    {
        for m in self.mid {
            let minterAccess <- self.minterRef.createMinterAccess(mid: m)
            let metadata <- self.metadataRef.generateMetadata(minter: <-minterAccess)
            let nft <- self.minterRef.mintNFT(metadata: <-metadata)
            self.collectionRef.depositByAgent(token: <-nft, index: self.index!, feature: self.feature.contains(m), permission: self.agentRef)
            
            log("Minted & Transfered")
        }
    }
}
 