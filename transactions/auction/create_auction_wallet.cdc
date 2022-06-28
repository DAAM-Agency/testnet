// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V8 from 0x01837e15023c9249

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V8.AuctionWallet>(from: AuctionHouse_V8.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V8.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V8.createAuctionWallet()
            self.signer.save<@AuctionHouse_V8.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V8.auctionStoragePath)
            self.signer.link<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>
                (AuctionHouse_V8.auctionPublicPath, target: AuctionHouse_V8.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
