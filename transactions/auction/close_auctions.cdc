// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse from0x1837e15023c9249

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
            (AuctionHouse.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
