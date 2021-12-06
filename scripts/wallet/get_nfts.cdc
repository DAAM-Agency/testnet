// get_nfts.cdc

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [&DAAM_V7.NFT] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V7.CollectionPublic}>(DAAM_V7.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
     let ids = collectionRef.getIDs()
     var nfts: [&DAAM_V7.NFT] = []
     for id in ids {
         nfts.append(collectionRef.borrowDAAM(id: id))
     }

     return nfts
}
