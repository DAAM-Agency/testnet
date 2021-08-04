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
    pub event AuctionReturned(tokenID: UInt64)
    pub event BidMade(tokenID: UInt64, bidder: Address )
    pub event AuctionCollected(winner: Address, tokenID: UInt64)
    pub event BuyItNow(winner: Address, token: UInt64, amount: UFix64)
    pub event FundsReturned()
    // Path
    pub let auctionStoragePath: StoragePath
    pub let auctionPublicPath : PublicPath
    // Variables

/************************************************************************/
    pub resource AuctionWallet {
        priv let titleholder  : Address
        pub var currentAuctions: @{UInt64 : Auction}

        init(owner: Address) {
            self.titleholder = owner
            self.currentAuctions <- {}
        }

        pub fun createAuction(ownerCollection: Capability<&DAAM.Collection>, tokenID: UInt64, start: UFix64, length: UFix64, isExtended: Bool,
          extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64)
        {
            pre {
                self.titleholder == self.owner!.address   : "You are not the owner."
                !self.currentAuctions.containsKey(tokenID): "Already created an Auction for this TokenID."
            }
            post { self.currentAuctions.containsKey(tokenID) }
            
            let auction <- create Auction(ownerCollection: ownerCollection, tokenID: tokenID, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow)
                         
            let oldAuction <- self.currentAuctions[tokenID] <- auction
            destroy oldAuction
            
            log("Auction Created. Start: ".concat(start.toString()) )
            emit AuctionCreated(tokenID: tokenID)
        }

        pub fun closeAuctions() {
            pre {
                self.titleholder == self.owner!.address  : "You are not the owner."
            }

            for act in self.currentAuctions.keys {
                self.currentAuctions[act]?.updateStatus()
                let status  = self.currentAuctions[act]?.status
                if status == false {
                    let tokenID = self.currentAuctions[act]?.tokenID!
                    self.currentAuctions[act]?.verifyWinnerPrice()
                    let auction <- self.currentAuctions.remove(key:tokenID)!
                    destroy auction
                    

                    log("Auction Closed: ".concat(tokenID.toString()) )
                    emit AuctionClosed(tokenID: tokenID)
                }
            }
        }

        pub fun item(_ id: UInt64): &Auction {
            pre { self.currentAuctions.containsKey(id) }
            return &self.currentAuctions[id] as &Auction
        }

        destroy() {
            destroy self.currentAuctions
        }
    }
/************************************************************************/
    pub resource Auction {
        access(contract) var status: Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        pub let ownerCollection: Capability<&DAAM.Collection>
        pub let tokenID     : UInt64
        pub let start       : UFix64
        pub var length      : UFix64  // post{!isExtended && length == before(length)}
        pub let isExtended  : Bool
        pub let extendedTime: UFix64 // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase.
        pub var leader      : Address?
        pub var minBid      : UFix64?
        pub let increment   : {Bool : UFix64} // true = is amount, false = is percentage *Note 1.0 = 100%
        pub let startingBid : UFix64
        pub let reserve     : UFix64
        pub let buyNow      : UFix64
        pub var auctionLog  : {Address: UFix64} // {Bidders, Amount}
        priv var auctionVault: @FungibleToken.Vault
    
        init(ownerCollection: Capability<&DAAM.Collection>, tokenID: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
          incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64) {
            pre {
                start > getCurrentBlock().timestamp : "Time has already past."
                length > 1.0 as UFix64              : "Minimum is 1 hour"  // 1 hour = 3600  // TODO rest 1.0 to 3599.99
                startingBid > 0.0                   : "You can not have a Starting Bid of zero."
                reserve > startingBid || reserve == 0.0 : "The Reserve must be greater then ypur Starting Bid"
                buyNow > reserve || buyNow == 0.0   : "The BuyNow option must be greater then the Reserve."
            }

            if incrementByPrice == false && incrementAmount <= 0.025 { panic("The minimum increment is 2.5%.")   }
            if incrementByPrice == false && incrementAmount > 0.05  { panic("The minimum increment is 5%.")     }
            if incrementByPrice == true  && incrementAmount < 1.0   { panic("The minimum increment is 1 FUSD.") }

            self.ownerCollection = ownerCollection
            self.status = nil
            self.tokenID = tokenID
            self.start = start
            self.length = length
            self.leader = nil
            self.minBid = startingBid
            self.isExtended = isExtended
            self.extendedTime = extendedTime
            self.increment = {incrementByPrice : incrementAmount}
            
            self.startingBid = startingBid
            self.reserve = reserve
            self.buyNow = buyNow
            self.auctionLog = {}
            self.auctionVault <- FlowToken.createEmptyVault()
        
            log("Auction Initialized: ".concat(self.tokenID.toString()) )
            emit AuctionCreated(tokenID: self.tokenID)
        }

        pub fun depositToBid(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {         
                self.minBid != nil                        : "No Bidding. Buy It Now."     
                self.updateStatus() != false              : "Auction has already ended."
                self.validateBid(balance: amount.balance) : "You have made an invalid Bid."
                self.leader != bidder.address             : "You are already lead bidder."
                self.owner?.address != bidder.address     : "Yo can not bid in your own auction."
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

            log("Bid Accepted")
            emit BidMade(tokenID: self.tokenID, bidder:self.leader! )
        }

        priv fun validateBid(balance: UFix64): Bool {
            log("Balance: ".concat(balance.toString()) )
            log("Min Bid: ".concat(self.minBid!.toString()) )
            if self.leader == nil { // First Bid
                if balance >= self.minBid! {
                    return true
                }
                log("Initial Bid too low.")
                return false
            } 
            // Not the first bid
            if self.auctionLog.containsKey(self.leader!) &&
              (balance + self.auctionLog[self.leader!]!) >= self.minBid! {
                return true
            }
            log("Bid Deposit too low.")
            return false
        }

        priv fun incrementminBid() {
            let bid = self.auctionLog[self.leader!]!
            if self.increment[false] != nil { // percentage increment
                self.minBid = bid + (bid * self.increment[false]!)
            } else { // price incremnt
                self.minBid = bid + self.increment[true]!
            }
        }

        access(contract) fun updateStatus(): Bool? {
            let end = self.start + self.length
            if self.status == false {  // false = Auction has Ended
                log("Auction had already ended.")
                return false
            }      
            let timeNow = getCurrentBlock().timestamp
            if self.start < timeNow {  // nil = Auction hasn't startepd
                log("")
                return nil
            } else if timeNow > end {  // false = Auction has Ended
                return false
            } 
            return true
        }

        pub fun withdrawBid(bidder: AuthAccount): @FungibleToken.Vault {
            pre {
                self.updateStatus() != false : "Auction has Ended."
                self.auctionLog.containsKey(bidder.address)
                self.minBid != nil
            }
            let bidder_address = bidder.address
            let balance = self.auctionLog[bidder_address]!
            self.auctionLog.remove(key: bidder_address)
            let amount <- self.auctionVault.withdraw(amount: balance)!
            return <- amount
        }

        pub fun winnerCollect(bidder: AuthAccount) {
            pre{
                self.minBid != nil
                self.leader! == bidder.address : "You do not have access to the selected Auction"
            }
            self.verifyWinnerPrice()
        }

        access(contract) fun verifyWinnerPrice() {
            pre { self.updateStatus() == false   : "Auction still in progress" }
            // Does it meet the reserve price?
            if self.auctionLog[self.leader!]! >= self.reserve {
                let ownerCollectionRef = self.ownerCollection.borrow()!
                let nft <- ownerCollectionRef.withdraw(withdrawID: self.tokenID)
                // remove leader from log before returnFunds()!!
                self.auctionLog.remove(key: self.leader!)!
                self.returnFunds()!
                self.royality()
                let collectionRef = getAccount(self.leader!).getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath).borrow()!
                collectionRef.deposit(token: <- nft)
                log("Auction Collected")
                emit AuctionCollected(winner: self.leader!, tokenID: self.tokenID)                
                // serial minter
            } else {
                self.returnFunds()!
                log("Auction Returned")
                emit AuctionReturned(tokenID: self.tokenID)    
            }                  
        }

        pub fun buyItNow(bidder: AuthAccount, amount: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.updateStatus() != false  : "Auction has Ended."
                self.buyItNowStatus()         : "Buy It Now option has expired."
                self.buyNow == amount.balance : "Wrong Amount."
            }
            // ends the auction
            self.status = false  
            self.length = 0.0 as UFix64
            self.auctionVault.deposit(from: <- amount)
            self.leader = bidder.address
            // remove leader from log before returnFunds!!!
            self.auctionLog.remove(key: bidder.address)!
            self.returnFunds()!
            self.royality()
            
            let ownerCollectionRef = self.ownerCollection.borrow()!
            let nft <- ownerCollectionRef.withdraw(withdrawID: self.tokenID)

            // serial minter

            log("Buy It Now")
            emit BuyItNow(winner: self.leader!, token: self.tokenID, amount: self.buyNow)
            return <- nft
        }    

        
        pub fun buyItNowStatus(): Bool {
            return self.buyNow != 0.0 && self.buyNow > self.auctionLog[self.leader!]!
        }

        priv fun returnFunds() {
            for bidder in self.auctionLog.keys {
                let bidderRef =  getAccount(bidder).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!
                let amount <- self.auctionVault.withdraw(amount: self.auctionLog[bidder]!)
                bidderRef.deposit(from: <- amount)
            }
            self.auctionLog = {}

            log("Funds Returned")
            emit FundsReturned()
        }

        pub fun cancelAuction(auctioneer: AuthAccount): @NonFungibleToken.NFT {
            pre {
                self.updateStatus() == nil  : "Too late to cancel Auction."
                self.auctionLog.length == 0 : "You already have a bid. Too late to Cancel."
                self.owner?.address! == auctioneer.address: "You are not the auctioneer."
            }
            
            self.status = false
            self.length = 0.0 as UFix64

            let ownerCollectionRef = self.ownerCollection.borrow()!
            let nft <- ownerCollectionRef.withdraw(withdrawID: self.tokenID)

            log("Auction Cancelled: ".concat(self.tokenID.toString()) )
            emit AuctionCancelled(tokenID: self.tokenID)
            return <- nft
        }

        priv fun extendAuction() {
            if !self.isExtended { return }
            self.length = self.length + self.extendedTime
        }

        pub fun getStatus(): Bool? {
            return self.status
        }

        pub fun timeLeft(): UFix64 {
            //self.updateStatus()
            if self.length == 0.0 {
                return 0.0 as UFix64
            }
            let end = self.start + self.length
            let timeNow = getCurrentBlock().timestamp
            if end <= timeNow {
                let timeleft = timeNow - end
                return timeleft
            }
            return 0.0 as UFix64
        }

        priv fun royality() {
            if self.auctionVault.balance == 0.0 {
                return
            }
/*
            let nft <- self.auctionNFT <- nil

            let price = self.auctionVault.balance
            let creator = nft.metadata.creator!
            let agencyPercentage  = nft!.royality[DAAM.agency]!
            let creatorPercentage = nft!.royality[creator]!    

            self.auction <- nft

            let agencyRoyality  = DAAM.newNFTs.contains(self.tokenID) ? 0.2 : agencyPercentage
            let creatorRoyality = DAAM.newNFTs.contains(self.tokenID) ? 0.8 : creatorPercentage
            // If 1st sale set remove from 'new list'
            if DAAM.newNFTs.contains(self.tokenID) { 
                AuctionHouse.notNew(tokenID: self.tokenID)
            } // no longer "new"
            let agencyCut  <-! self.auctionVault.withdraw(amount: price * agencyRoyality)
            let creatorCut <-! self.auctionVault.withdraw(amount: price * creatorRoyality)

            let agencyPay  = getAccount(DAAM.agency).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!
            let creatorPay = getAccount(creator).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!

            agencyPay.deposit(from: <-agencyCut)
            creatorPay.deposit(from: <-creatorCut)

            if self.auctionVault.balance != 0.0 {
                panic("Royality Error")
            }*/
        }

        priv fun updateSeries() {
            //if self.nftRef.metadata.series == 1 as UInt64 { return } // 1 shot only
            //if self.owner?.address != self.nftRef.metadata.creator { return } // Is this the original Creators' wallet?

            //Marketplace.loadMinter(creator: creator, mid: mid, price: price, recipient: self.ownerCollection.borrow()! )
        }

        destroy() {
            pre{ self.status == false }
            self.returnFunds()
            self.royality()

            destroy self.auctionVault
        }
    }
/************************************************************************/
// AuctionHouse Functions & Constructor
    access(contract) fun notNew(tokenID: UInt64) {
        let minter = self.account.borrow<&DAAM.Creator{DAAM.SeriesMinter}>(from: DAAM.creatorStoragePath)!
        minter.notNew(tokenID: tokenID)
    }

    pub fun createAuctionWallet(owner: AuthAccount): @AuctionWallet {
        return <- create AuctionWallet(owner: owner.address)
    }

    init() {
        self.auctionStoragePath = /storage/DAAM_Auction
        self.auctionPublicPath  = /public/DAAM_Auction
    }
}
