// close_auction.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_Mainnet from 0x01837e15023c9249

transaction(auction: Address, aid: UInt64) {
    let auctionHouse : &AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}
    let aid: UInt64

    prepare(signer: AuthAccount) {
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
            (AuctionHouse_Mainnet.auctionPublicPath)
            .borrow()!
        
        self.aid = aid
    }

    execute {
        self.auctionHouse.closeAuction(self.aid)
        log("Auction Closed:".concat(self.aid.toString()))
    }
}
