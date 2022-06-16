// check_auction_wallet.cdc
// Checks to see if there is an Auction Wallet

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse_V3     from 0x045a1763c93006ca

pub fun main(auction: Address): Bool {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V3.AuctionWallet{AuctionHouse_V3.AuctionWalletPublic}>
        (AuctionHouse_V3.auctionPublicPath)
        .borrow()!
        
    return auction != nil
}
