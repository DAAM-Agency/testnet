// winner_collect.cdc
// Used to claim an item. Must meet reserve price.

import AuctionHouse_V7  from 0x01837e15023c9249
transaction(auction: Address, aid: UInt64)
{ 
    let aid          : UInt64
    let auctionHouse : &AuctionHouse_V7.AuctionWallet{AuctionHouse_V7.AuctionWalletPublic}
    
    prepare(signer: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V7.AuctionWallet{AuctionHouse_V7.AuctionWalletPublic}>
            (AuctionHouse_V7.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.item(self.aid)!.winnerCollect()
    }
}
