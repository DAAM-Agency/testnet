// delete_auction_wallet.cdc
// Debugging Tool

import AuctionHouse_V5 from 0x045a1763c93006ca

transaction() {
    let auction: AuthAccount

    prepare(auction: AuthAccount) {
        self.auction = auction
        let auctionRes  <- self.auction.load<@AuctionHouse_V5.AuctionWallet>(from: AuctionHouse_V5.auctionStoragePath)
        destroy auctionRes
        self.auction.unlink(AuctionHouse_V5.auctionPublicPath)
        log("AuctionHouse_V5 cleared.")
    }    
}
