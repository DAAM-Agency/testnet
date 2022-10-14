// mint_to_collection.cdc
// Used for Admin / Agent to mint on behalf in their Creator

//import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews    from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

pub fun compareArray(_ mids: [UInt64], _ features: [UInt64]) {
    for f in features {
        if !mids.contains(f) { panic("MID: ".concat(f.toString().concat(" can not be Featured."))) }
    }
}

transaction(creator: Address, mid: [UInt64], name: String, feature: [UInt64])
{
    let minterRef : &DAAM.Minter
    let mid       : [UInt64]
    let feature   : [UInt64]
    let index     : Int?
    let metadataRef  : &{DAAM.MetadataGeneratorMint}
    let collectionRef: &DAAM.Collection{DAAM.CollectionPublic}
    let agentRef     : &DAAM.Admin{DAAM.Agent}

    prepare(minter: AuthAccount) {
        compareArray(mid, feature)
        self.minterRef = minter.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        self.mid       = mid
        self.feature   = feature

        self.collectionRef  = getAccount(creator)
            .getCapability(DAAM.collectionPublicPath)
            .borrow<&DAAM.Collection{DAAM.CollectionPublic}>()!

        self.metadataRef = getAccount(creator)
            .getCapability(DAAM.metadataPublicPath)
            .borrow<&{DAAM.MetadataGeneratorMint}>()!
        
        self.agentRef = minter.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!

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
 