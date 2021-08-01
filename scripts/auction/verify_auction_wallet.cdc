// verify_auction_wallet.cdc

import NonFungibleToken from 0x120e725050340cab
import AuctionHouse     from 0x045a1763c93006ca

pub fun main(account: Address): Bool {
    let auction = getAccount(account)
        .getCapability<&AuctionHouse.AuctionWallet>(AuctionHouse.auctionPublicPath)
        .borrow()
    let status = (auction != nil)
    return status
}
