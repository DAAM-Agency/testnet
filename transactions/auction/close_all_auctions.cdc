// close_all_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_Mainnet from 0x01837e15023c9249

transaction() {
    let auctions: [Address]

    prepare(signer: AuthAccount) {
        self.auctions =  AuctionHouse_Mainnet.getCurrentAuctions().keys!
    }

    execute {
        for auction in self.auctions {
            let auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
            (AuctionHouse_Mainnet.auctionPublicPath)
            .borrow()!

            auctionHouse.closeAuctions()
        }
        log("Auctions Closed")
    }
}
