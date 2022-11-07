// get_crypto.cdc
// Return all accepted Cryptos/Tokens in AuctionHouse_Mainnet

import AuctionHouse_Mainnet from 0x045a1763c93006ca

pub fun main(): [String] {    
    return AuctionHouse_Mainnet.getCrypto()
}