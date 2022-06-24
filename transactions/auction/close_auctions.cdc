// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

<<<<<<< HEAD
import AuctionHouse_V4 from 0x1837e15023c9249

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
            (AuctionHouse_V4.auctionPublicPath)
=======
import AuctionHouse_V5 from 0x045a1763c93006ca

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
            (AuctionHouse_V5.auctionPublicPath)
>>>>>>> DAAM_V15
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
