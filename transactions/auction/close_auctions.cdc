// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_V6 from 0x01837e15023c9249

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_V6.AuctionWallet{AuctionHouse_V6.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V6.AuctionWallet{AuctionHouse_V6.AuctionWalletPublic}>
            (AuctionHouse_V6.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
