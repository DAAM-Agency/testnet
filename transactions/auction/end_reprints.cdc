// end_reprints.cdc
// to toggle reprints to OFF.

import AuctionHouse_V11 from 0x01837e15023c9249

transaction(aid: UInt64) {
    let aid    : UInt64
    let auctionHouse : &AuctionHouse_V11.AuctionWallet

    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = signer.borrow<&AuctionHouse_V11.AuctionWallet>(from: AuctionHouse_V11.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.endReprints(auctionID: self.aid)
        log("Ending Reprints")
    }
}
