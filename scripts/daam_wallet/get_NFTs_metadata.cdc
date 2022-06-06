// get_NFTs_metadata.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [&DAAM.NFT] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
     let ids = collectionRef.getIDs()
     var nfts: [&DAAM.NFT] = []
     for id in ids {
         nfts.append(collectionRef.borrowDAAM(id: id))
     }
     return nfts
}
