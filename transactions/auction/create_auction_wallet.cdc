// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse from 0x045a1763c93006ca

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath) == nil {
            let auctionWallet <- AuctionHouse.createAuctionWallet(auctioneer: self.signer)
            self.signer.save<@AuctionHouse.AuctionWallet> (<- auctionWallet, to: AuctionHouse.auctionStoragePath)
            self.signer.link<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath, target: AuctionHouse.auctionStoragePath)
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
