// get_crypto.cdc
// Return all accepted Cryptos/Tokens in AuctionHouse

import AuctionHouse from 0x045a1763c93006ca

pub fun main(): [String] {    
    return AuctionHouse.getCrypto()
}