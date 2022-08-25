// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V15 from 0x045a1763c93006ca

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V15.AuctionWallet>(from: AuctionHouse_V15.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V15.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V15.createAuctionWallet()
            self.signer.save<@AuctionHouse_V15.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V15.auctionStoragePath)
            self.signer.link<&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}>
                (AuctionHouse_V15.auctionPublicPath, target: AuctionHouse_V15.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
