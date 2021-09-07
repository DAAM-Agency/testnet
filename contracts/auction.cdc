// auction.cdc
// by Ami Rajpal, 2021 // DAAM Agency

import FungibleToken    from 0x9a0766d93b6608b7
import FlowToken        from 0x7e60df042a9c0868
import DAAM_V3          from 0xa4ad5ea5c0bd2fba
import NonFungibleToken from 0x631e88ae7f1d7c20
import FUSD             from 0xe223d8a629e49c68

pub contract AuctionHouse_V1 {
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
    // Note: Do not confuse (Token)ID with MID
    access(contract) var metadataGen : {UInt64 : Capability<&DAAM_V3.MetadataGenerator>} // {MID  :Capability<&DAAM.MetadataGenerator>}

/************************************************************************/
    pub resource interface AuctionPublic {
        // Public Interface for AuctionWallet
        pub fun getAuctions(): [UInt64] // MIDs in Auctions
        pub fun item(_ id: UInt64): &Auction // item(Token ID) will return the apporiate auction.
    }
/************************************************************************/
    pub resource AuctionWallet: AuctionPublic {
        pub let titleholder  : Address  // owner of the wallet
        pub var currentAuctions: @{UInt64 : Auction}  // { TokenID : Auction }
        

        init(auctioneer: AuthAccount) {
            self.titleholder = auctioneer.address
            self.currentAuctions <- {}            
        }

        // Creates a 'new' auction. It is Minted here, and auctioned. Creates an auction for 'Submitted NFT'
        // new is defines as "never sold", age is not a consideration.
        pub fun createOriginalAuction(metadataGenerator: Capability<&DAAM.MetadataGenerator>, mid: UInt64, start: UFix64, length: UFix64,
        isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
        {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
                metadataGenerator != nil : "There is no Metadata."
                }

            AuctionHouse_V1.metadataGen.insert(key: mid, metadataGenerator) // add access to Creators' Metadata
            let metadataRef = AuctionHouse_V1.metadataGen[mid]!.borrow()!   
            let metadata <- metadataRef.generateMetadata(mid: mid)!      // Create MetadataHolder
            let nft <- AuctionHouse_V1.mintNFT(metadata: <-metadata)        // Create NFT

            self.createAuction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime, incrementByPrice: incrementByPrice,
            incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)
        }

        // Creates an auction for a NFT.
        pub fun createAuction(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
            reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
        {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
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

        // Closes all Auctions that have Ended". All funds and items are delegated accordingly.
        pub fun closeAuctions() {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
            }

            for act in self.currentAuctions.keys {
                self.currentAuctions[act]?.updateStatus()
                let current_status = self.currentAuctions[act]?.status // status value may be changed with verifyReservePrive by seriesMinter
                if current_status == false {
                    let tokenID = self.currentAuctions[act]?.tokenID!
                    self.currentAuctions[act]?.verifyReservePrice()! // does it meet the reserve price?
                    if self.currentAuctions[act]?.status == true { continue }  // Series Minter is minting another Metadata to NFT restarting.
                    let auction <- self.currentAuctions.remove(key:tokenID)!   // No Series minting or last...
                    destroy auction                                            // end auction.

                    log("Auction Closed: ".concat(tokenID.toString()) )
                    emit AuctionClosed(tokenID: tokenID)
                }
            }
        }

        pub fun item(_ id: UInt64): &Auction { // item(Token ID) return a reference of the tokenID Auction
            pre { self.currentAuctions.containsKey(id) }
            return &self.currentAuctions[id] as &Auction
        }        

        pub fun getAuctions(): [UInt64] { return self.currentAuctions.keys } // return all auctions by User

        destroy() { destroy self.currentAuctions }
    }
/************************************************************************/
    pub resource Auction {
        access(contract) var status: Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        pub var tokenID     : UInt64
        pub var start       : UFix64  // timestamp
        pub let origLength  : UFix64  
        pub var length      : UFix64  // post{!isExtended && length == before(length)}
        pub let isExtended  : Bool    // true = Auction extends with every bid.
        pub let extendedTime: UFix64  // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
        pub var leader      : Address? // leading bidder
        pub var minBid      : UFix64? // minimum bid
        pub let increment   : {Bool : UFix64} // true = is amount, false = is percentage *Note 1.0 = 100%
        pub let startingBid : UFix64  // starting bid
        pub let reserve     : UFix64  // the reserve. must be sold at min price.
        pub let buyNow      : UFix64  // buy now price
        pub let reprintSeries: Bool   // Active Series Minter (if series)
        pub var auctionLog   : {Address: UFix64} // {Bidders, Amount} // Log of the Auction
        pub var auctionNFT  : @DAAM.NFT?
        priv var auctionVault: @FungibleToken.Vault // Vault, All funds are stored.
    
        init(nft: @DAAM_V3.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
          incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool) {
            pre {
                start >= getCurrentBlock().timestamp : "Time has already past."
                length > 1.0 as UFix64              : "Minimum is 1 hour"  // 1 hour = 3600  // TODO rest 1.0 to 3599.99
                startingBid > 0.0                   : "You can not have a Starting Bid of zero."
                reserve > startingBid || reserve == 0.0 : "The Reserve must be greater then ypur Starting Bid"
                buyNow > reserve || buyNow == 0.0   : "The BuyNow option must be greater then the Reserve."
                isExtended && extendedTime >= 60.0 || !isExtended && extendedTime == 0.0: "Extended Time setting are incorrect. The minimim is 1 min."
                reprintSeries == true && nft.metadata.series != 1 || !reprintSeries : "This can be reprinted."
            }

            if incrementByPrice == false && incrementAmount < 0.025 { panic("The minimum increment is 2.5%.")   }
            if incrementByPrice == false && incrementAmount > 0.05  { panic("The maximum increment is 5%.")     }
            if incrementByPrice == true  && incrementAmount < 1.0   { panic("The minimum increment is 1 FUSD.") }

            self.status = nil
            self.tokenID = nft.id
            self.start = start
            self.length = length
            self.origLength = length
            self.leader = nil
            self.minBid = startingBid
            self.isExtended = isExtended
            self.extendedTime = (isExtended) ? extendedTime : 0.0 as UFix64
            self.increment = {incrementByPrice : incrementAmount}
            
            self.startingBid = startingBid
            self.reserve = reserve
            self.buyNow = buyNow
            // if last in series don't reprint.
            self.reprintSeries = nft.metadata.series == nft.metadata.counter ? false : reprintSeries

            self.auctionLog = {}
            self.auctionVault <- FUSD.createEmptyVault()

            self.auctionNFT <- nft

            log("Auction Initialized: ".concat(self.tokenID.toString()) )
            emit AuctionCreated(tokenID: self.tokenID)
        }

        // Makes Bid, Bids are deposited into vault
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
            self.incrementminBid() // increment accordingly
            self.auctionVault.deposit(from: <- amount)
            self.extendAuction() // If extendend auction... extend

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

        // Returns the current status of the Auction
        access(contract) fun updateStatus(): Bool? {
            if self.status == false {  // false = Auction has Ended
                log("Status: Auction Previously Ended")
                return false
            }

            let auction_time = self.timeLeft()
            if auction_time == 0.0 {
                self.status = false
                log("Status: Time Limit Reached & Auction Ended")
                return false
            }

            if auction_time == nil {
                log("Status: Not Started")
                return nil
            }
            return true
        }

        // Return all Funds made durning auction. // Not lead bidder
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

        // Winner can make a 'claim' to item...
        pub fun winnerCollect(bidder: AuthAccount) {
            pre{
                self.minBid != nil
                self.leader! == bidder.address : "You do not have access to the selected Auction"
            }
            self.verifyReservePrice() // ... Reserve Price verification is the next step.
        }

        access(contract) fun verifyReservePrice() {
            pre  { self.updateStatus() == false   : "Auction still in progress" }
            post { self.verifyAuctionLog() }

            var target = self.leader
            let metadataRef = self.getMetadataRef()

            if self.leader != nil {
                target = self.leader!
                // Does it meet the reserve price?
                if self.auctionLog[self.leader!]! >= self.reserve {
                    // remove leader from log before returnFunds()!!
                    self.auctionLog.remove(key: self.leader!)!
                    self.returnFunds()!
                    self.royality()
                    log("Item: Won")
                    emit AuctionCollected(winner: self.leader!, tokenID: self.tokenID) // Auction Ended, but Item not delivered yet.
                    // possible re-auction Series Minter
                    self.resetAuction()
                    self.seriesMinter(mid: metadataRef.mid)
                    
                }             
            } else {                
                target = metadataRef.creator!          
                self.returnFunds()!
                log("Item: Returned")
                emit AuctionReturned(tokenID: self.tokenID)    
            }          
            let collectionRef = getAccount(target!).getCapability<&{DAAM_V3.CollectionPublic}>(DAAM_V3.collectionPublicPath).borrow()!
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
            
            self.status = false  // ends the auction
            self.length = 0.0 as UFix64  // set length to 0; double end auction
            self.auctionVault.deposit(from: <- amount)  // depsoit
            self.leader = bidder.address                // set new leader
            self.auctionLog.remove(key: bidder.address) // remove from auction log
            self.returnFunds()!                         // return reameaning bids
            self.royality()                             // pay royalities
            // nft deposot Must be LAST !!!
            let nft <- self.auctionNFT <- nil           // get nft
            let mid  = nft?.metadata?.mid!      

            log("Buy It Now")
            emit BuyItNow(winner: self.leader!, token: self.tokenID, amount: self.buyNow)
            
            self.resetAuction()         // Only if SeriesMinter Conditions apply
            self.seriesMinter(mid: mid) // Only if SeriesMinter Conditions apply
            
            return <- nft!              // give NFT
        }    

        // returns BuyItNowStaus, true = active, false = inactive
        pub fun buyItNowStatus(): Bool { 
            if self.leader != nil {
                return self.buyNow > self.auctionLog[self.leader!]!
            }
            return true
        }

        // return all funds in auction log
        priv fun returnFunds() {
            for bidder in self.auctionLog.keys {
                let bidderRef =  getAccount(bidder).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
                let amount <- self.auctionVault.withdraw(amount: self.auctionLog[bidder]!)
                bidderRef.deposit(from: <- amount)
            }
            self.auctionLog = {}

            log("Funds Returned")
            emit FundsReturned()
        }

        // Auctions can be cancelled if they have no bids. 
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
            // nft deposit Must be LAST !!!
            let nft <- self.auctionNFT <- nil
            return <- nft!
        }

        priv fun extendAuction() { // extends auction by extendedTime
            if !self.isExtended { return }
            self.length = self.length + self.extendedTime
        }

        pub fun getStatus(): Bool? { // gets Auction status: nil=not started, true=ongoing, false=ended
            return self.status
        }

        pub fun timeLeft(): UFix64? { // returns time left, nil = not started yet.
            if self.length == 0.0 {
                return 0.0 as UFix64
            } // Extended Auction ended.

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

        // Royality rates are gathered from the NFTs metadata and funds are proportioned accordingly. 
        priv fun royality()
        {
            post { self.auctionVault.balance == 0.0 : "Royality Error" } // The Vault should always end empty

            if self.auctionVault.balance == 0.0 { return } // No need to run, already processed.
            let price = self.auctionVault.balance   // get price of NFT
            let metadataRef = self.getMetadataRef() // get NFT Metadata Reference
            let royality = self.getRoyality()       // get all royalities percentages

            let agencyPercentage  = royality[DAAM.agency]!          // extract Agency percentage
            let creatorPercentage = royality[metadataRef.creator]!  // extract creators percentage using Metadata Reference

            let agencyRoyality  = DAAM.newNFTs.contains(self.tokenID) ? 0.15 : agencyPercentage  // If 'new' use default 15% for Agency.  First Sale Only.
            let creatorRoyality = DAAM.newNFTs.contains(self.tokenID) ? 0.85 : creatorPercentage // If 'new' use default 85% for Creator. First Sale Only.
            // If 1st sale is 'new' remove from 'new list'
            if DAAM.newNFTs.contains(self.tokenID) { AuctionHouse_V1.notNew(tokenID: self.tokenID) } // no longer "new"

            let agencyCut  <-! self.auctionVault.withdraw(amount: price * agencyRoyality)  // Calculate Agency FUSD share
            let creatorCut <-! self.auctionVault.withdraw(amount: price * creatorRoyality) // Calculate Creator FUSD share
            // get FUSD Receivers for Agency & Creator
            let agencyPay  = getAccount(DAAM.agency).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
            let creatorPay = getAccount(metadataRef.creator).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
            
            agencyPay.deposit(from: <-agencyCut)  // Deposit into accounts
            creatorPay.deposit(from: <-creatorCut)
        }

        // Comapres Log to Vault. Makes sure Funds match. Should always be true!
        priv fun verifyAuctionLog(): Bool {
            var total = 0.0
            for amount in self.auctionLog.keys {
                total = total + self.auctionLog[amount]!
            }
            return total == self.auctionVault.balance
        }

        // get Metadata Reference
        pub fun getMetadataRef(): &DAAM.Metadata { // Redundent Remove, item(mid).auctionNFT.borrowDAAM() verify TODO
            let ref = &self.auctionNFT?.metadata! as &DAAM.Metadata
            return ref 
        }

        // return royality information
        priv fun getRoyality(): {Address : UFix64} {
            let royality = self.auctionNFT?.royality!
            return royality 
        }

        priv fun seriesMinter(mid: UInt64) {
            if !self.reprintSeries { return } // if reprint is set to off (false) return
            let metadataGen = AuctionHouse_V1.metadataGen[mid]!.borrow()!
            let metadataRef = self.getMetadataRef()
            let creator = metadataRef.creator
            if creator != self.owner?.address! { return }  // verify owner is creator
            let metadata <- metadataGen.generateMetadata(mid: mid)
            let nft <- AuctionHouse_V1.mintNFT(metadata: <-metadata)
            self.tokenID = nft.id                         // get new Token ID
            let old <- self.auctionNFT <- nft             // move nft into auctionNFT for auction
            destroy old
        } 

        // resets all variables that need to be reset
        priv fun resetAuction() {
            if !self.reprintSeries { return } // if reprint is set to off (false) return   
            self.status = true        
            self.leader = nil
            self.start = getCurrentBlock().timestamp
            self.length = self.origLength
            self.auctionLog = {}
            self.minBid = self.startingBid
            log("Reset: Variables")
        }

        destroy() { // Verify no Funds/NFT are in storage
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

    // Sets NFT to 'not new' 
    access(contract) fun notNew(tokenID: UInt64) {
        let minter = self.account.borrow<&DAAM_V3.Minter>(from: DAAM_V3.minterStoragePath)!
        minter.notNew(tokenID: tokenID)
    }

    // Requires Minter Key // Minter function to mint
    access(contract) fun mintNFT(metadata: @DAAM.MetadataHolder): @DAAM.NFT {
        let minter = self.account.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
        let nft <- minter.mintNFT(metadata: <-metadata)!
        return <- nft
    }

    pub fun createAuctionWallet(auctioneer: AuthAccount): @AuctionWallet {
        return <- create AuctionWallet(auctioneer: auctioneer)
    }

    init() {
        self.metadataGen = {}
        self.auctionStoragePath = /storage/DAAM_Auction
        self.auctionPublicPath  = /public/DAAM_Auction
    }
}
