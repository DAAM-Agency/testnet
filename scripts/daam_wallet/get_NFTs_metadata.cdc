// get_NFTs_metadata.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [&DAAM_Mainnet.NFT] {
     let collectionRef = getAccount(account).getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")
     
     let daamRef = getAccount(account).getCapability<&{DAAM_Mainnet.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")

     let ids = collectionRef.getIDs()
     var nfts: [&DAAM_Mainnet.NFT] = []

     for id in ids { nfts.append(daamRef.borrowDAAM_Mainnet(id: id)) }
     return nfts
}
