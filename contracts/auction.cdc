// auction.cdc
// by Ami Rajpal, 2021 // DAAM Agency

import FungibleToken    from 0xee82856bf20e2aa6
import FlowToken        from 0x0ae53cb6e3f42a79
import DAAM             from 0xfd43f9148d4b725d
import NonFungibleToken from 0x120e725050340cab

pub contract AuctionHouse {
    // Events
    pub event AuctionInitialized()
    pub event AuctionCreated(tokenID: UInt64)
    pub event AuctionClosed(tokenID: UInt64)
    pub event AuctionCancelled(tokenID: UInt64)
    pub event BidMade(tokenID: UInt64, bidder: Address )
    pub event AuctionCollected(winner: Address, tokenID: UInt64)
    pub event BuyItNow(winner: Address, token: UInt64, amount: UFix64)
    pub event FundsReturned()
    // Path
    pub let auctionStoragePath: StoragePath
    pub let auctionPublicPath : PublicPath
/************************************************************************/
    pub resource AuctionWallet {
        priv let titleholder  : Address
        pub var currentAuction: @{UInt64 : Auction}

        init(owner: Address) {
            self.titleholder = owner
            self.currentAuction <- {}
        }

        pub fun createAuction(token: @NonFungibleToken.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, increment: {Bool:UFix64},
        startingBid: UFix64, reserve: UFix64, buyNow: UFix64) {
            pre {
                self.titleholder == self.owner!.address   : "You are not the owner."
                !self.currentAuction.containsKey(token.id): "Already created an Auction for this TokenID."
            }
            post { self.currentAuction.containsKey(id) }

            let id = token.id
            let auction <- create Auction(token: <- token, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              increment: increment, startingBid: startingBid, reserve: reserve, buyNow: buyNow)
                         
            let oldAuction <- self.currentAuction[id] <- auction
            destroy oldAuction
            
            log("Auction Created. Start: ".concat(start.toString()) )
            emit AuctionCreated(tokenID: id)
        }

        pub fun closeAuctions() {
            pre {
                self.titleholder == self.owner!.address  : "You are not the owner."
            }

            for act in self.currentAuction.keys {
                let status  = self.currentAuction[act]?.status!
                if status == false {
                    let tokenID = self.currentAuction[act]?.tokenID!
                    self.currentAuction[act]?.verifyWinnerPrice()
                    let auction <- self.currentAuction.remove(key:tokenID)!
                    destroy auction

                    log("Auction Closed: ".concat(tokenID.toString()) )
                    emit AuctionClosed(tokenID: tokenID)
                }
            } 
        }

        destroy() { destroy self.currentAuction }
    }
/************************************************************************/
    pub resource Auction {
        access(contract) var status: Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        pub let tokenID     : UInt64
        pub let start       : UFix64
        pub var length      : UFix64  // post{!isExtended && length == before(length)}
        pub let isExtended  : Bool
        pub let extendedTime: UFix64 // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase.
        pub var leader      : Address?
        pub var minBid      : UFix64
        pub let increment   : {Bool : UFix64} // true = is amount, false = is percentage *Note 1.0 = 100%
        pub let startingBid : UFix64
        pub let reserve     : UFix64
        pub let buyNow      : UFix64
        pub var auctionLog  : {Address: UFix64} // {Bidders, Amount}
        priv var auctionVault: @FungibleToken.Vault
        pub var auctionNFT   : @NonFungibleToken.NFT?
    
        init(token: @NonFungibleToken.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, increment: {Bool:UFix64},
          startingBid: UFix64, reserve: UFix64, buyNow: UFix64) {
            pre {
                start > getCurrentBlock().timestamp : "Time has already past."
                length > 3599.99 as UFix64          : "Minimum is 1 hour"  // 1 hour = 3600
                startingBid > 0.0                   : "You can not have a Starting Bid of zero."
                reserve > startingBid || reserve == 0.0 : "The Reserve must be greater then ypur Starting Bid"
                buyNow > reserve || buyNow == 0.0   : "The BuyNow option must be greater then the Reserve."
                increment.length == 1               : "Your increment is not valid"
                increment[false] != nil && increment[false]! <= 0.025 : "The minimum increment is 2.5%."
                increment[false] != nil && increment[false]! >= 0.05 : "The minimum increment is 5%."
                increment[true] != nil && increment[true]! >= 1.0 : "The minimum increment is 1 FUSD."
            }
            self.status = nil
            self.tokenID = token.id
            self.start = start
            self.length = length
            self.leader = nil
            self.minBid = startingBid
            self.isExtended = isExtended
            self.extendedTime = extendedTime
            self.increment = increment
            self.startingBid = startingBid
            self.reserve = reserve
            self.buyNow = buyNow
            self.auctionLog = {}
            self.auctionVault <- FlowToken.createEmptyVault()
            self.auctionNFT <- token 

            log("Auction Initialized: ".concat(self.tokenID.toString()) )
            emit AuctionCreated(tokenID: self.tokenID)
        }

        pub fun makeBid(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {                 
                self.updateStatus() != false : "Auction already ended."
                // First Bid
                (!self.auctionLog.containsKey(self.leader!) && amount.balance >= self.minBid) ||
                  // Not the first bid
                (self.auctionLog.containsKey(self.leader!) && 
                (amount.balance + self.auctionLog[self.leader!]!) >= self.minBid)
            }
            self.leader = bidder.address
            if !self.auctionLog.containsKey(self.leader!) { // First bid by user
                self.auctionLog.insert(key: self.leader!, amount.balance)
            } else {
                let total = self.auctionLog[self.leader!]! + amount.balance
                self.auctionLog[self.leader!] = total
            }            
            self.incrementminBid()
            self.auctionVault.deposit(from: <- amount)
            self.extendAuction()

            log("Bid Made")
            emit BidMade(tokenID: self.tokenID, bidder:self.leader! )
        }

        priv fun incrementminBid() {
            let bid = self.auctionLog[self.leader!]!
            if self.increment[false] != nil { // percentage increment
                self.minBid = bid + (bid * self.increment[false]!)
            } else { // price incremnt
                self.minBid = bid + self.increment[true]!
            }
        }

        priv fun updateStatus(): Bool? {
            pre { self.status != false }
            let timeNow = getCurrentBlock().timestamp                            
            if self.start >= timeNow {
                self.status = (self.start + self.length) < timeNow ? true : false
            }
            return self.status
        }

        pub fun withdrawBid(bidder: AuthAccount, wallet: @FungibleToken.Vault): @FungibleToken.Vault {
            pre {
                self.updateStatus() != false : "Auction has Ended."
                self.auctionLog.containsKey(bidder.address)
            }
            let bidder_address = bidder.address
            let balance = self.auctionLog[bidder_address]!
            self.auctionLog.remove(key: bidder_address)
            let amount <- self.auctionVault.withdraw(amount: balance)!
            wallet.deposit(from: <- amount)
            self.updateStatus()
            return <- wallet
        }

        pub fun winnerCollect(bidder: AuthAccount) {
            pre{ self.leader! == bidder.address : "You do not have access to the selected Auction" }
            self.verifyWinnerPrice()
        }

        access(contract) fun verifyWinnerPrice() {
            pre { self.updateStatus() == false   : "Auction still in progress" }

            var nft <- self.auctionNFT <- nil
            let item_collector = (self.auctionLog[self.leader!]! >= self.reserve) ? self.leader! : self.owner?.address!            
            // return nft to accordingly // Auctionier or winner
            let collectionRef = getAccount(item_collector).getCapability<&{DAAM.CollectionPublic}>
                (DAAM.collectionPublicPath).borrow()!
            collectionRef.deposit(token: <- nft!)

            self.auctionLog.remove(key: self.leader!)
            self.returnFunds()!

            log("Auction Collected")
            emit AuctionCollected(winner: self.leader!, tokenID: self.tokenID)          
        }

       pub fun buyItNow(bidder: AuthAccount, amount: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.updateStatus() != false   : "Auction has Ended."
                self.buyItNowStatus()
                self.buyNow == amount.balance
            }
            self.status = false  // ends the auction
            self.leader = bidder.address          
            self.auctionVault.deposit(from: <- amount)
            self.auctionLog.remove(key: bidder.address)
            self.returnFunds()!
            let nft <- self.auctionNFT <- nil

            log("Buy It Now")
            emit BuyItNow(winner: self.leader!, token: self.tokenID, amount: self.buyNow)
            return <- nft!
        }    

        
        pub fun buyItNowStatus(): Bool {
            return self.buyNow != 0.0 && self.buyNow > self.auctionLog[self.leader!]!
        }

        priv fun returnFunds() {
            pre { !self.auctionLog.containsKey(self.leader!) }
            for bidder in self.auctionLog.keys {
                let bidderRef =  getAccount(bidder).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!
                let amount <- self.auctionVault.withdraw(amount: self.auctionLog[bidder]!)
                bidderRef.deposit(from: <- amount)
            }
            self.auctionLog = {}

            log("Funds Returned")
            emit FundsReturned()
        }

        pub fun cancelAuction(): @NonFungibleToken.NFT {
            pre {
                self.updateStatus() == nil  : "Too late to cancel Auction."
                self.auctionLog.length == 0 : "You already have a bid. Too late to Cancel."
            }
            self.status = false            
            let nft <- self.auctionNFT <- nil

            log("Auction Cancelled: ".concat(self.tokenID.toString()) )
            emit AuctionCancelled(tokenID: self.tokenID)
            return <- nft!
        }

        priv fun extendAuction() {
            if !self.isExtended { return }
            self.length = self.length + self.extendedTime
        }

        pub fun getStatus(): Bool? {
            return self.status
        }

        destroy() {
            pre{ self.status == false }
            self.returnFunds()
            let amount <- self.auctionVault.withdraw(amount: self.auctionVault.balance)
            let receiver = getAccount(self.owner?.address!).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!
            receiver.deposit(from: <- amount)

            destroy self.auctionVault
            destroy self.auctionNFT
        }
    }
/************************************************************************/
    pub fun createAuctionWallet(owner: AuthAccount): @AuctionWallet {
        return <- create AuctionWallet(owner: owner.address)
    }

    init() {
        self.auctionStoragePath = /storage/DAAM_Auction
        self.auctionPublicPath  = /public/DAAM_Auction
    }
}