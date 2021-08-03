// but_it_now.cdc

//import FungibleToken from 0xee82856bf20e2aa6
//import FlowToken     from 0x0ae53cb6e3f42a79
import AuctionHouse  from 0x045a1763c93006ca
import DAAM          from 0xfd43f9148d4b725d

transaction(auction: Address, tokenID: UInt64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &AuctionHouse.AuctionWallet
    //let flowStoragePath : StoragePath
    let collection      : &{DAAM.CollectionPublic}
    
    prepare(auctioneer: AuthAccount) {
        self.bidder = bidder
        //self.flowStoragePath = /storage/flowTokenVault
        self.auctionHouse = getAccount(auction).getCapability<&AuctionHouse.AuctionWallet>(AuctionHouse.auctionPublicPath).borrow()!
        self.collection = getAccount(bidder.address).getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath).borrow()!
    }

    execute {
        //let vaultRef = self.bidder.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: self.flowStoragePath)!
        //let amount <- vaultRef.withdraw(amount: bid)!
        let nft <- self.auctionHouse.item(tokenID)!.cancelAuction(auctioneer: auctioneer)!
        self.collection.deposit(token: <- nft)
    }
}
