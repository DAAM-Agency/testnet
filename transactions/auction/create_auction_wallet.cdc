// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V9 from 0x01837e15023c9249

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V9.AuctionWallet>(from: AuctionHouse_V9.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V9.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V9.createAuctionWallet()
            self.signer.save<@AuctionHouse_V9.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V9.auctionStoragePath)
            self.signer.link<&AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}>
                (AuctionHouse_V9.auctionPublicPath, target: AuctionHouse_V9.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
