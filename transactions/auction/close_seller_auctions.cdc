// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_V9 from 0x01837e15023c9249

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}>
            (AuctionHouse_V9.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
