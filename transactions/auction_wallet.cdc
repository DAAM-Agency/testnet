// auction_wallet.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse_V1     from 0x045a1763c93006ca

// This transaction is what an account would run to set itself up to receive NFTs
transaction()
{
    prepare(acct: AuthAccount) {
        let auction = acct.borrow<&AuctionHouse_V1.AuctionWallet>(from: AuctionHouse_V1.auctionStoragePath)
        if auction == nil {
            let new_auction <- AuctionHouse_V1.createAuctionWallet(owner: acct)
            acct.save<@AuctionHouse_V1.AuctionWallet>(<- new_auction, to: AuctionHouse_V1.auctionStoragePath)
            acct.link<&AuctionHouse_V1.AuctionWallet>( AuctionHouse_V1.auctionPublicPath, target:  AuctionHouse_V1.auctionStoragePath)
            log("Auction Wallet Created.")
        } else {
            log("You already have an Auction Wallet.")
        }
    }
}// transaction
