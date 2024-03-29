// get_auction_log.cdc

import AuctionHouse_Mainnet  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
