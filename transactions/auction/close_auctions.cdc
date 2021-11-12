// close_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse from 0x01837e15023c9249

transaction()
{
    let auctionHouse : &AuctionHouse.AuctionWallet

    prepare(signer: AuthAccount) {
        self.auctionHouse = signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
