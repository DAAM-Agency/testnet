// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse_Mainnet from 0x045a1763c93006ca

transaction() {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        if self.signer.borrow<&AuctionHouse_Mainnet.AuctionWallet>(from: AuctionHouse_Mainnet.auctionStoragePath) == nil {
            let old <- self.signer.load<@AnyResource>(from: AuctionHouse_Mainnet.auctionStoragePath)
            let auctionWallet <- AuctionHouse_Mainnet.createAuctionWallet()
            self.signer.save<@AuctionHouse_Mainnet.AuctionWallet> (<- auctionWallet, to: AuctionHouse_Mainnet.auctionStoragePath)
            self.signer.link<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
                (AuctionHouse_Mainnet.auctionPublicPath, target: AuctionHouse_Mainnet.auctionStoragePath)
            destroy old
            log("Auction House Created, you can now have Auctions.")
        }
        else {
            log("You already have an Auction House.")
        }
    }    
}
