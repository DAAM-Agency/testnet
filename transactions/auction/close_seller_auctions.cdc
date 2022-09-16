// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

<<<<<<< HEAD
import AuctionHouse_V16 from 0x01837e15023c9249
=======
import AuctionHouse_V16 from 0x01837e15023c9249
>>>>>>> tomerge

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
