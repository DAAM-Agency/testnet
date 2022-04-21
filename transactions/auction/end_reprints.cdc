// end_reprints.cdc
// to toggle reprints to OFF.

import AuctionHouse_V2 from 0x1837e15023c9249

transaction(aid: UInt64) {
    let aid    : UInt64
    let auctionHouse : &AuctionHouse_V2.AuctionWallet

    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = signer.borrow<&AuctionHouse_V2.AuctionWallet>(from: AuctionHouse_V2.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.endReprints(auctionID: self.aid)
        log("Ending Reprints")
    }
}
