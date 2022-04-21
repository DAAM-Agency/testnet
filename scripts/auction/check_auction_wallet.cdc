// check_auction_wallet.cdc
// Checks to see if there is an Auction Wallet

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse_V2  from 0x1837e15023c9249

pub fun main(account: Address): Bool {
    let auction = getAccount(account)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()
    return auction != nil
}
