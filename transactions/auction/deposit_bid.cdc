// deposit_bid.cdc
// Used to make bids on item. Is accumulative with each bid. 

import FungibleToken        from 0x9a0766d93b6608b7
import FUSD                 from 0xe223d8a629e49c68
import AuctionHouse_Mainnet from 0x01837e15023c9249

transaction(auction: Address, aid: UInt64, bid: UFix64)
{
    let bidder          : Address
    let auctionHouse    : &AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}
    let fusdStoragePath : StoragePath
    let vaultRef        : &FUSD.Vault{FungibleToken.Provider}
    let aid             : UInt64
    let bid             : UFix64
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder.address
        self.aid = aid
        self.bid = bid
        
        self.fusdStoragePath = /storage/fusdVault
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
            (AuctionHouse_Mainnet.auctionPublicPath)
            .borrow()!
        self.vaultRef = bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
    }

    execute {
        let amount <- self.vaultRef.withdraw(amount: self.bid)!
        self.auctionHouse.item(self.aid)!.depositToBid(bidder: self.bidder, amount: <-amount)!
    }
}
