// check_auction_wallet.cdc
// Checks to see if there is an Auction Wallet

import NonFungibleToken from 0xf8d6e0586b0a20c7
import AuctionHouse     from 0x045a1763c93006ca

pub fun main(account: Address): Bool {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
        (AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auction != nil
}
