
// create_auction_wallet.cdc

import AuctionHouse from 0x045a1763c93006ca

transaction()
{ // TODO Update
    //let signer: AuthAccount

    prepare(signer: AuthAccount) {
        //self.signer = signer
        if signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath) == nil {
            let auctionWallet <- AuctionHouse.createAuctionWallet(auctioneer: signer)
            signer.save<@AuctionHouse.AuctionWallet> (<- auctionWallet, to: AuctionHouse.auctionStoragePath)
            signer.link<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath, target: AuctionHouse.auctionStoragePath)
            log("Auction House Created, you can now have Auctions.")
            return
        }
        log("You already have an Auction House.")
    }
    
    //pre { self.signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) }
}
