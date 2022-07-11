// check_auction_wallet.cdc
// Checks to see if there is an Auction Wallet

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse_V9     from 0x01837e15023c9249

pub fun main(auction: Address): Bool {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}>
        (AuctionHouse_V9.auctionPublicPath)
        .borrow()!
        
    return auctionHouse != nil
}
