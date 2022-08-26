// check_auction_wallet.cdc
// Checks to see if there is an Auction Wallet

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse_V16     from 0x01837e15023c9249

pub fun main(auction: Address): Bool {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
        (AuctionHouse_V16.auctionPublicPath)
        .borrow()
        
    return auctionHouse != nil
}
