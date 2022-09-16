// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_V16 from 0x045a1763c93006ca

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
            (AuctionHouse_V16.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
