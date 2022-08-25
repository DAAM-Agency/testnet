// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V17 from 0x045a1763c93006ca

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V17.AuctionWallet>(from: AuctionHouse_V17.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V17.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V17.createAuctionWallet()
            self.signer.save<@AuctionHouse_V17.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V17.auctionStoragePath)
            self.signer.link<&AuctionHouse_V17.AuctionWallet{AuctionHouse_V17.AuctionWalletPublic}>
                (AuctionHouse_V17.auctionPublicPath, target: AuctionHouse_V17.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
