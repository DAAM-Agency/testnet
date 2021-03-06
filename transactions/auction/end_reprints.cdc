// end_reprints.cdc
// to toggle reprints to OFF.

import AuctionHouse_V14 from 0x045a1763c93006ca

transaction(aid: UInt64) {
    let aid    : UInt64
    let auctionHouse : &AuctionHouse_V14.AuctionWallet

    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = signer.borrow<&AuctionHouse_V14.AuctionWallet>(from: AuctionHouse_V14.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.endReprints(auctionID: self.aid)
        log("Ending Reprints")
    }
}
