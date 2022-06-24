// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V5 from 0x045a1763c93006ca

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V5.AuctionWallet>(from: AuctionHouse_V5.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V5.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V5.createAuctionWallet()
            self.signer.save<@AuctionHouse_V5.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V5.auctionStoragePath)
            self.signer.link<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
                (AuctionHouse_V5.auctionPublicPath, target: AuctionHouse_V5.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
