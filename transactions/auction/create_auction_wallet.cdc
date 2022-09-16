// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

<<<<<<< HEAD
import AuctionHouse_V16 from 0x01837e15023c9249
=======
import AuctionHouse_V16 from 0x01837e15023c9249
>>>>>>> tomerge

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V16.AuctionWallet>(from: AuctionHouse_V16.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V16.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V16.createAuctionWallet()
            self.signer.save<@AuctionHouse_V16.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V16.auctionStoragePath)
            self.signer.link<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
                (AuctionHouse_V16.auctionPublicPath, target: AuctionHouse_V16.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
