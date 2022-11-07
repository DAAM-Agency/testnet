// get_NFTs_metadata.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(account: Address): [&DAAMDAAM_Mainnet_Mainnet.NFT] {
     let collectionRef = getAccount(account).getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")
     
     let daamRef = getAccount(account).getCapability<&{DAAM_Mainnet.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath).borrow()
     ?? panic("Could not borrow capability from public collection")

     let ids = collectionRef.getIDs()
     var nfts: [&DAAMDAAM_Mainnet_Mainnet.NFT] = []

     for id in ids { nfts.append(daamRef.borrowDAAM_Mainnet(id: id)) }
     return nfts
}
