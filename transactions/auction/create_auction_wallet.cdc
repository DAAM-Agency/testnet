// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V14 from 0x045a1763c93006ca

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V14.AuctionWallet>(from: AuctionHouse_V14.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V14.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V14.createAuctionWallet()
            self.signer.save<@AuctionHouse_V14.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V14.auctionStoragePath)
            self.signer.link<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
                (AuctionHouse_V14.auctionPublicPath, target: AuctionHouse_V14.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
