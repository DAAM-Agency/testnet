// get_NFTs_metadata.cdc

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [&DAAM_V10.NFT] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V10.CollectionPublic}>(DAAM_V10.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
     let ids = collectionRef.getIDs()
     var nfts: [&DAAM_V10.NFT] = []
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [&DAAM_V14.NFT] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V14.CollectionPublic}>(DAAM_V14.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
     let ids = collectionRef.getIDs()
     var nfts: [&DAAM_V14.NFT] = []
>>>>>>> DAAM_V14
     for id in ids {
         nfts.append(collectionRef.borrowDAAM(id: id))
     }
     return nfts
}
