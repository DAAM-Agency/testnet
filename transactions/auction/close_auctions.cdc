
// close_auctions.cdc

import AuctionHouse_V1 from 0x045a1763c93006ca

transaction()
{
    let auctionHouse : &AuctionHouse_V1.AuctionWallet

    prepare(signer: AuthAccount) {
        self.auctionHouse = signer.borrow<&AuctionHouse_V1.AuctionWallet>(from: AuctionHouse_V1.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.closeAuctions()
        log("Auction Closed")
    }
}
