// close_all_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse from 0x045a1763c93006ca

transaction() {
    let auctions: [Address]

    prepare(signer: AuthAccount) {
        self.auctions =  AuctionHouse.getCurrentAuctions().keys!
    }

    execute {
        for auction in self.auctions {
            let auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
            (AuctionHouse.auctionPublicPath)
            .borrow()!

            auctionHouse.closeAuctions()
        }
        log("Auctions Closed")
    }
}
