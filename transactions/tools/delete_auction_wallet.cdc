// delete_auction_wallet.cdc
// Debugging Tool

import AuctionHouse from 0x045a1763c93006ca

transaction() {
    let auction: AuthAccount

    prepare(auction: AuthAccount) {
        self.auction = auction
        let auctionRes  <- self.auction.load<@AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        self.auction.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse cleared.")
    }    
}
