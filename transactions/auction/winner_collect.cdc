// winner_collect.cdc
// Used to claim an item. Must meet reserve price.

<<<<<<< HEAD
import AuctionHouse_V4  from 0x1837e15023c9249
transaction(auction: Address, aid: UInt64)
{ 
    let aid          : UInt64
    let auctionHouse : &AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}
=======
import AuctionHouse_V5  from 0x045a1763c93006ca
transaction(auction: Address, aid: UInt64)
{ 
    let aid          : UInt64
    let auctionHouse : &AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}
>>>>>>> DAAM_V15
    
    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = getAccount(auction)
<<<<<<< HEAD
            .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
            (AuctionHouse_V4.auctionPublicPath)
=======
            .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
            (AuctionHouse_V5.auctionPublicPath)
>>>>>>> DAAM_V15
            .borrow()!
    }

    execute {
        self.auctionHouse.item(self.aid)!.winnerCollect()
    }
}
