// auction_wallet.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import AuctionHouse     from 0x01837e15023c9249

// This transaction is what an account would run to set itself up to receive NFTs
transaction()
{
    prepare(acct: AuthAccount) {
        let auction = acct.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)
        if auction == nil {
            let new_auction <- AuctionHouse.createAuctionWallet(owner: acct)
            acct.save<@AuctionHouse.AuctionWallet>(<- new_auction, to: AuctionHouse.auctionStoragePath)
            acct.link<&AuctionHouse.AuctionWallet>( AuctionHouse.auctionPublicPath, target:  AuctionHouse.auctionStoragePath)
            log("Auction Wallet Created.")
        } else {
            log("You already have an Auction Wallet.")
        }
    }
}// transaction
