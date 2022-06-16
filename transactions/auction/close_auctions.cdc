// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_V4 from 0x045a1763c93006ca

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
            (AuctionHouse_V4.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
