// delete_auction_wallet.cdc
// Debugging Tool

import AuctionHouse_Mainnet from 0x045a1763c93006ca

transaction() {
    let auction: AuthAccount

    prepare(auction: AuthAccount) {
        self.auction = auction
        let auctionRes  <- self.auction.load<@AuctionHouse_Mainnet.AuctionWallet>(from: AuctionHouse_Mainnet.auctionStoragePath)
        destroy auctionRes
        self.auction.unlink(AuctionHouse_Mainnet.auctionPublicPath)
        log("AuctionHouse_Mainnet cleared.")
    }    
}
