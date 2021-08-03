
// close_auction.cdc

import AuctionHouse     from 0x045a1763c93006ca

transaction()
{
    prepare(signer: AuthAccount) {
        let auctionHouse = signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
        auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
