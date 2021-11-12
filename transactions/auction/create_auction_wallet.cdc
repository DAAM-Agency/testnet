// create_auction_wallet.cdc
// Create an auction wallet. Used to store auctions.

import AuctionHouse from 0x01837e15023c9249

transaction() {
    //let signer: AuthAccount

    prepare(signer: AuthAccount) {
        if signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath) == nil {
            let auctionWallet <- AuctionHouse.createAuctionWallet(auctioneer: signer)
            signer.save<@AuctionHouse.AuctionWallet> (<- auctionWallet, to: AuctionHouse.auctionStoragePath)
            signer.link<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath, target: AuctionHouse.auctionStoragePath)
            log("Auction House Created, you can now have Auctions.")
            return
        }
        log("You already have an Auction House.")
    }    
}
