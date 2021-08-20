
// create_auction_wallet.cdc

import AuctionHouse_V1 from 0x045a1763c93006ca

transaction()
{
    prepare(signer: AuthAccount) {
        if signer.borrow<&AuctionHouse_V1.AuctionWallet>(from: AuctionHouse_V1.auctionStoragePath) == nil {
            let auctionWallet <- AuctionHouse_V1.createAuctionWallet(auctioneer: signer)
            signer.save<@AuctionHouse_V1.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V1.auctionStoragePath)
            signer.link<&{AuctionHouse_V1.AuctionPublic}>(AuctionHouse_V1.auctionPublicPath, target: AuctionHouse_V1.auctionStoragePath)
            log("Auction House Created, you can now have Auctions.")
            return
        }
        log("You already have an Auction House.")
    }
}
