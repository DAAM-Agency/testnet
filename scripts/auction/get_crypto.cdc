// get_crypto.cdc
// Return all accepted Cryptos/Tokens in AuctionHouse_Mainnet

import AuctionHouse_Mainnet from 0x01837e15023c9249

pub fun main(): [String] {    
    return AuctionHouse_Mainnet.getCrypto()
}