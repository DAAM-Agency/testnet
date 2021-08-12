
// close_auctions.cdc

import AuctionHouse from 0x045a1763c93006ca

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
