// auction_status.cdc

import AuctionHouse  from 0x045a1763c93006ca

pub fun main(auction: Address, tokenID: UInt64): Bool? {    
    let auctionHouse = getAccount(auction).getCapability<&AuctionHouse.AuctionWallet>(AuctionHouse.auctionPublicPath).borrow()!
    return auctionHouse.item(tokenID)!.getStatus()
}
