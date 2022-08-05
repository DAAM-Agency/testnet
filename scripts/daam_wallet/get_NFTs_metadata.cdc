// get_NFTs_metadata.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [&DAAM.NFT] {
     let collectionRef = getAccount(account).getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")
     
     let daamRef = getAccount(account).getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")

     let ids = collectionRef.getIDs()
     var nfts: [&DAAM.NFT] = []

     for id in ids { nfts.append(daamRef.borrowDAAM(id: id)) }
     return nfts
}
