// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_V11 from 0x01837e15023c9249

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_V11.AuctionWallet>(from: AuctionHouse_V11.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_V11.auctionStoragePath)
            let auctionWallet <- AuctionHouse_V11.createAuctionWallet()
            self.signer.save<@AuctionHouse_V11.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V11.auctionStoragePath)
            self.signer.link<&AuctionHouse_V11.AuctionWallet{AuctionHouse_V11.AuctionWalletPublic}>
                (AuctionHouse_V11.auctionPublicPath, target: AuctionHouse_V11.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
