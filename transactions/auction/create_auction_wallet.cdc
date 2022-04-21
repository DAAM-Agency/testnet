// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V2 from 0x1837e15023c9249

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V2.AuctionWallet>(from: AuctionHouse_V2.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V2.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V2.createAuctionWallet(auctioneer: self.signer)
            self.signer.save<@AuctionHouse_V2.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V2.auctionStoragePath)
            self.signer.link<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath, target: AuctionHouse_V2.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
