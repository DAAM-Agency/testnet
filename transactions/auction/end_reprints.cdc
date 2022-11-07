// end_reprints.cdc
// to toggle reprints to OFF.

import AuctionHouse_Mainnet from 0x045a1763c93006ca

transaction(aid: UInt64) {
    let aid    : UInt64
    let auctionHouse : &AuctionHouse_Mainnet.AuctionWallet

    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = signer.borrow<&AuctionHouse_Mainnet.AuctionWallet>(from: AuctionHouse_Mainnet.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.endReprints(auctionID: self.aid)
        log("Ending Reprints")
    }
}
