// get_NFTs_metadata.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V20 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [&DAAM_V20.NFT] {
     let collectionRef = getAccount(account).getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM_V20.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")
     
     let daamRef = getAccount(account).getCapability<&{DAAM_V20.CollectionPublic}>(DAAM_V20.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")

     let ids = collectionRef.getIDs()
     var nfts: [&DAAM_V20.NFT] = []

     for id in ids { nfts.append(daamRef.borrowDAAM(id: id)) }
     return nfts
}
