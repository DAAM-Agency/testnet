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
    pub event BidWithdrawn(bidder: Address)    
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

        pub fun createOriginalAuction(metadata: @DAAM.MetadataHolder, start: UFix64, length: UFix64, isExtended: Bool,
        extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
        {
            let nft <- AuctionHouse.mintNFT(metadata: <-metadata)

            self.createAuction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime, incrementByPrice: incrementByPrice,
            incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)
        }

        pub fun createAuction(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool,
          extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
        {
            pre {
                self.titleholder == self.owner!.address   : "You are not the owner."
                !self.currentAuctions.containsKey(nft.id): "Already created an Auction for this TokenID."
            }
            let id = nft.id
            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)
                         
            let oldAuction <- self.currentAuctions[id] <- auction
            destroy oldAuction
            
            log("Auction Created. Start: ".concat(start.toString()) )
            emit AuctionCreated(tokenID: id)
        }

        pub fun closeAuctions() {
            pre {
                self.titleholder == self.owner!.address  : "You are not the owner."
            }

            for act in self.currentAuctions.keys {
                self.currentAuctions[act]?.updateStatus()
                let status = self.currentAuctions[act]?.status
                if status == false {
                    let tokenID = self.currentAuctions[act]?.tokenID!
                    let auction <- self.currentAuctions.remove(key:tokenID)!
                    auction.verifyReservePrice()
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
        pub let reprintSeries: Bool
        pub var auctionLog   : {Address: UFix64} // {Bidders, Amount}
        pub var auctionNFT  : @DAAM.NFT?
        priv var auctionVault: @FungibleToken.Vault
        // nft data
        priv let creator : Address
        priv let series : Bool
        priv let agencyPercentage: UFix64
        priv let creatorPercentage: UFix64
        priv let mid: UInt64
    
        init(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
          incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool) {
            pre {
                start > getCurrentBlock().timestamp : "Time has already past."
                length > 1.0 as UFix64              : "Minimum is 1 hour"  // 1 hour = 3600  // TODO rest 1.0 to 3599.99
                startingBid > 0.0                   : "You can not have a Starting Bid of zero."
                reserve > startingBid || reserve == 0.0 : "The Reserve must be greater then ypur Starting Bid"
                buyNow > reserve || buyNow == 0.0   : "The BuyNow option must be greater then the Reserve."
                isExtended && extendedTime >= 60.0 || !isExtended : "Extended Time setting are incorrect. The minimim is 1 min."
                reprintSeries == true && nft.metadata.series != 0 || !reprintSeries : "This can be reprinted."
            }
            post { self.auctionNFT != nil}
            
            if incrementByPrice == false && incrementAmount <= 0.025 { panic("The minimum increment is 2.5%.")   }
            if incrementByPrice == false && incrementAmount > 0.05   { panic("The maximum increment is 5%.")     }
            if incrementByPrice == true  && incrementAmount < 1.0    { panic("The minimum increment is 1 FUSD.") }

            self.status = nil
            self.tokenID = nft.id
            self.start = start
            self.length = length
            self.leader = nil
            self.minBid = startingBid
            self.isExtended = isExtended
            self.extendedTime = (isExtended) ? extendedTime : 0.0 as UFix64
            self.increment = {incrementByPrice : incrementAmount}
            
            self.startingBid = startingBid
            self.reserve = reserve
            self.buyNow = buyNow
            self.reprintSeries = reprintSeries
            self.auctionLog = {}
            self.auctionVault <- FlowToken.createEmptyVault()

            self.creator = nft.metadata.creator!
            self.agencyPercentage  = nft.royality[DAAM.agency]!
            self.creatorPercentage = nft.royality[self.creator]!
            self.mid = nft.metadata.mid!
            // 1 shot only or Series finished
            self.series = (nft.metadata.series == 1 as UInt64) || (nft.metadata.series == nft.metadata.counter)? false : true

            self.auctionNFT <- nft         
        
            log("Auction Initialized: ".concat(self.tokenID.toString()) )
            emit AuctionCreated(tokenID: self.tokenID)
        }

        pub fun depositToBid(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {         
                self.minBid != nil                    : "No Bidding. Buy It Now."     
                self.updateStatus() == true           : "Auction is not in progress."
                self.validateBid(bidder: bidder.address, balance: amount.balance) : "You have made an invalid Bid."
                self.leader != bidder.address         : "You are already lead bidder."
                self.owner?.address != bidder.address : "Yo can not bid in your own auction."
            }
            post { self.verifyAuctionLog() }

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

            log("Balance: ".concat(self.auctionLog[self.leader!]!.toString()) )
            log("Min Bid: ".concat(self.minBid!.toString()) )

            log("Bid Accepted")
            emit BidMade(tokenID: self.tokenID, bidder:self.leader! )
        }

        priv fun validateBid(bidder: Address, balance: UFix64): Bool {
            // Bidders' first bid (New Bidder)
            if !self.auctionLog.containsKey(bidder) {
                if balance >= self.minBid! {
                    return true
                }
                log("Initial Bid too low.")
                return false
            }
            // Otherwise ... (not the Bidders' first bid)
            if (balance + self.auctionLog[bidder]!) >= self.minBid! {
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
            if self.status == false {  // false = Auction has Ended
                log("Auction had already ended.")
                return false
            }      

            let auction_time = self.timeLeft()
            if auction_time == 0.0 {
                self.status = false
                log("Auction had already ended.")
                return false
            }

            if auction_time == nil {
                log("Auction has not started yet.")
                return nil
            }
            return true
        }

        pub fun withdrawBid(bidder: AuthAccount): @FungibleToken.Vault {
            pre {
                self.leader! != bidder.address : "You have the Winning Bid. You can not withdraw."
                self.updateStatus() != false   : "Auction has Ended."
                self.auctionLog.containsKey(bidder.address) : "You have not made a Bid"
                self.minBid != nil : "This is a Buy It Now only purchase."
                self.verifyAuctionLog() : "Internal Error!!"
            }
            post { self.verifyAuctionLog() }
            let balance = self.auctionLog[bidder.address]!
            self.auctionLog.remove(key: bidder.address)!
            let amount <- self.auctionVault.withdraw(amount: balance)!
            log("Bid Withdrawn")
            emit BidWithdrawn(bidder: bidder.address)    
            return <- amount
        }

        pub fun winnerCollect(bidder: AuthAccount) {
            pre{
                self.minBid != nil
                self.leader! == bidder.address : "You do not have access to the selected Auction"
            }
            self.verifyReservePrice()
        }

        access(contract) fun verifyReservePrice() {
            pre  { self.updateStatus() == false   : "Auction still in progress" }
            post { self.verifyAuctionLog() }
            var target = self.leader
            if self.leader != nil {
                target = self.leader!
                // Does it meet the reserve price?
                if self.auctionLog[self.leader!]! >= self.reserve {
                    // remove leader from log before returnFunds()!!
                    self.auctionLog.remove(key: self.leader!)!
                    self.returnFunds()!
                    self.royality()
                    // serial minter TODO
                    log("Auction Collected")
                    emit AuctionCollected(winner: self.leader!, tokenID: self.tokenID)
                }             
            } else {
                target = self.creator
                self.returnFunds()!
                log("Auction Returned")
                emit AuctionReturned(tokenID: self.tokenID)    
            }          
            let collectionRef = getAccount(target!).getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath).borrow()!
            // nft deposot Must be LAST !!! 
            let nft <- self.auctionNFT <- nil            
            collectionRef.deposit(token: <- nft!)
        }

        pub fun buyItNow(bidder: AuthAccount, amount: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.updateStatus() != false  : "Auction has Ended."
                self.buyNow != 0.0 : "Buy It Now option is not available."
                self.buyNow == amount.balance : "Wrong Amount."
                // Must be after the above line.
                self.buyItNowStatus() : "Buy It Now option has expired."
            }
            post { self.verifyAuctionLog() }
            // ends the auction
            self.status = false  
            self.length = 0.0 as UFix64
            self.auctionVault.deposit(from: <- amount)
            self.leader = bidder.address
            self.auctionLog.remove(key: bidder.address)
            self.returnFunds()!
            self.royality()
            // serial minter TODO

            log("Buy It Now")
            emit BuyItNow(winner: self.leader!, token: self.tokenID, amount: self.buyNow)
            // nft deposot Must be LAST !!!
            let nft <- self.auctionNFT <- nil
            return <- nft!
        }    

        
        pub fun buyItNowStatus(): Bool {
            if self.leader != nil {
                return self.buyNow > self.auctionLog[self.leader!]!
            }
            return true
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
                self.updateStatus() == nil || true         : "Too late to cancel Auction."
                self.auctionLog.length == 0                : "You already have a bid. Too late to Cancel."
                self.owner?.address! == auctioneer.address : "You are not the auctioneer."
            }
            
            self.status = false
            self.length = 0.0 as UFix64

            log("Auction Cancelled: ".concat(self.tokenID.toString()) )
            emit AuctionCancelled(tokenID: self.tokenID)
            // nft deposot Must be LAST !!!
            let nft <- self.auctionNFT <- nil
            return <- nft!
        }

        priv fun extendAuction() {
            if !self.isExtended { return }
            self.length = self.length + self.extendedTime
        }

        pub fun getStatus(): Bool? {
            return self.status
        }

        pub fun timeLeft(): UFix64? {
            if self.length == 0.0 {
                return 0.0 as UFix64
            } // Extended Auction Ended is over

            let timeNow = getCurrentBlock().timestamp
            log("TimeNow: ".concat(timeNow.toString()) )

            let end = self.start + self.length
            log("End: ".concat(end.toString()) )

            if timeNow < self.start { return nil }
            
            if timeNow >= self.start && timeNow < end {
                let timeleft = end - timeNow
                return timeleft
            }
            return 0.0 as UFix64
        }

        priv fun royality() {
            if self.auctionVault.balance == 0.0 {
                return
            }
            let price = self.auctionVault.balance

            let agencyRoyality  = DAAM.newNFTs.contains(self.tokenID) ? 0.2 : self.agencyPercentage
            let creatorRoyality = DAAM.newNFTs.contains(self.tokenID) ? 0.8 : self.creatorPercentage
            // If 1st sale set remove from 'new list'
            if DAAM.newNFTs.contains(self.tokenID) { 
                AuctionHouse.notNew(tokenID: self.tokenID)
            } // no longer "new"

            let agencyCut  <-! self.auctionVault.withdraw(amount: price * agencyRoyality)
            let creatorCut <-! self.auctionVault.withdraw(amount: price * creatorRoyality)

            let agencyPay  = getAccount(DAAM.agency).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!
            let creatorPay = getAccount(self.creator).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow()!

            agencyPay.deposit(from: <-agencyCut)
            creatorPay.deposit(from: <-creatorCut)

            if self.auctionVault.balance != 0.0 {
                panic("Royality Error")
            }
        }

        priv fun updateSeries() {
            if !self.series { return }       
            if self.owner?.address != self.creator { return } // Is this the original Creators' wallet?
            // Minter Here TODO 
        }

        priv fun verifyAuctionLog(): Bool {
            var total = 0.0
            for amount in self.auctionLog.keys {
                total = total + self.auctionLog[amount]!
            }
            return total == self.auctionVault.balance
        }

        destroy() {
            pre{
                self.auctionNFT == nil
                self.status == false
                self.auctionVault.balance == 0.0
            }

            self.returnFunds()
            self.royality()

            destroy self.auctionVault
            destroy self.auctionNFT
        }
    }
/************************************************************************/
// AuctionHouse Functions & Constructor
    access(contract) fun notNew(tokenID: UInt64) {
        let minter = self.account.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        minter.notNew(tokenID: tokenID)
    }

    access(contract) fun mintNFT(metadata: @DAAM.MetadataHolder): @DAAM.NFT {
        let minter = self.account.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        let nft <- minter.mintNFT(metadata: <-metadata)!
        return <- nft
    }

    pub fun createAuctionWallet(owner: AuthAccount): @AuctionWallet {
        return <- create AuctionWallet(owner: owner.address)
    }

    init() {
        self.auctionStoragePath = /storage/DAAM_Auction
        self.auctionPublicPath  = /public/DAAM_Auction
    }
}
