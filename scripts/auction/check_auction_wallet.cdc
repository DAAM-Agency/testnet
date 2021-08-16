// verify_auction_wallet.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import AuctionHouse     from 0x045a1763c93006ca

pub fun main(account: Address): Bool {
    let auction = getAccount(account)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()
    let status = (auction != nil)
    return status
}
