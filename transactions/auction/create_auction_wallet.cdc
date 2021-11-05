
// create_auction_wallet.cdc

import AuctionHouse_V2 from 0x045a1763c93006ca

transaction()
{ // TODO Update
    //let signer: AuthAccount

    prepare(signer: AuthAccount) {
        if signer.borrow<&AuctionHouse_V2.AuctionWallet>(from: AuctionHouse_V2.auctionStoragePath) == nil {
            let auctionWallet <- AuctionHouse_V2.createAuctionWallet(auctioneer: signer)
            signer.save<@AuctionHouse_V2.AuctionWallet> (<- auctionWallet, to: AuctionHouse_V2.auctionStoragePath)
            signer.link<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath, target: AuctionHouse_V2.auctionStoragePath)
            log("Auction House Created, you can now have Auctions.")
            return
        }
        log("You already have an Auction House.")
    }
    
    //pre { self.signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) }
}
