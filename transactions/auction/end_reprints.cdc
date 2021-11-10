// end_reprints.cdc
// to toggle reprints to OFF.

import AuctionHouse from 0x045a1763c93006ca

transaction(auctionID: UInt64) {
    let auctionID    : UInt64
    let auctionHouse : &AuctionHouse.AuctionWallet

    prepare(signer: AuthAccount) {
        self.auctionID    = auctionID
        self.auctionHouse = signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.endReprints(auctionID: self.auctionID)
        log("Ending Reprints")
    }
}
