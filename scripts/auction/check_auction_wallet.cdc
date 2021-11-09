// check_auction_wallet.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse     from 0x045a1763c93006ca

pub fun main(account: Address): Bool {
    let auction = getAccount(account)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()
    let status = (auction != nil)
    return status
}
