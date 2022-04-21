// delete_auction_wallet.cdc
// Debugging Tool

import AuctionHouse_V2 from 0x045a1763c93006ca

transaction() {
    let auction: AuthAccount

    prepare(auction: AuthAccount) {
        self.auction = auction
        let auctionRes  <- self.auction.load<@AuctionHouse_V2.AuctionWallet>(from: AuctionHouse_V2.auctionStoragePath)
        destroy auctionRes
        self.auction.unlink(AuctionHouse_V2.auctionPublicPath)
        log("AuctionHouse_V2.cleared.")
    }    
}
