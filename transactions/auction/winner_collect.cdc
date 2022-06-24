// winner_collect.cdc
// Used to claim an item. Must meet reserve price.

import AuctionHouse_V5  from 0x045a1763c93006ca
transaction(auction: Address, aid: UInt64)
{ 
    let aid          : UInt64
    let auctionHouse : &AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}
    
    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
            (AuctionHouse_V5.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.item(self.aid)!.winnerCollect()
    }
}
