// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_Mainnet from 0x01837e15023c9249

transaction(auction: Address) {
    let auctionHouse : &AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
            (AuctionHouse_Mainnet.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
