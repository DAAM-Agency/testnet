// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V6 from 0x01837e15023c9249

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V6.AuctionWallet>(from: AuctionHouse_V6.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V6.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V6.createAuctionWallet()
            self.signer.save<@AuctionHouse_V6.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V6.auctionStoragePath)
            self.signer.link<&AuctionHouse_V6.AuctionWallet{AuctionHouse_V6.AuctionWalletPublic}>
                (AuctionHouse_V6.auctionPublicPath, target: AuctionHouse_V6.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
