// get_NFTs_metadata.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [&DAAM_V15.NFT] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V15.CollectionPublic}>(DAAM_V15.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
     let ids = collectionRef.getIDs()
     var nfts: [&DAAM_V15.NFT] = []
     for id in ids {
         nfts.append(collectionRef.borrowDAAM(id: id))
     }
     return nfts
}
