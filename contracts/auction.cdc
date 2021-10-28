// auction.cdc
// by Ami Rajpal, 2021 // DAAM Agency

import FungibleToken    from 0xee82856bf20e2aa6
import FUSD             from 0x192440c99cb17282
import DAAM             from 0xfd43f9148d4b725d
import NonFungibleToken from 0xf8d6e0586b0a20c7

pub contract AuctionHouse {
    // Events
    pub event AuctionInitialized()
    pub event AuctionCreated(auctionID: UInt64)
    pub event AuctionClosed(auctionID: UInt64)
    pub event AuctionCancelled(auctionID: UInt64)
    pub event AuctionReturned(auctionID: UInt64)
    pub event BidMade(auctionID: UInt64, bidder: Address )
    pub event BidWithdrawn(bidder: Address)    
    pub event AuctionCollected(winner: Address, auctionID: UInt64)
    pub event BuyItNow(winner: Address, auction: UInt64, amount: UFix64)
    pub event FundsReturned()
    // Path
    pub let auctionStoragePath: StoragePath
    pub let auctionPublicPath : PublicPath
    // Variables
    // Note: Do not confuse (Token)ID with MID
    access(contract) var metadataGen : {UInt64 : Capability<&DAAM.MetadataGenerator>} // { MID : Capability<&DAAM.MetadataGenerator> }
    access(contract) var auctionCounter : UInt64

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
        isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
        {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
                metadataGenerator != nil : "There is no Metadata."
                DAAM.copyright[mid] != DAAM.CopyrightStatus.FRAUD : "This submission has been flaged for Copyright Issues."
                DAAM.copyright[mid] != DAAM.CopyrightStatus.CLAIM : "This submission has been flaged for a Copyright Claim." 
                //!reprintSeries || (reprintSeries && nft.metadata.creator == self.owner?.address) : "You are not the Creator of this NFT"
                // Not neccessary, by default is the Creator tp access this very function.
            }

            AuctionHouse.metadataGen.insert(key: mid, metadataGenerator) // add access to Creators' Metadata
            let metadataRef = metadataGenerator.borrow()!
            let metadata <-! metadataRef.generateMetadata(mid: mid)      // Create MetadataHolder
            let nft <- AuctionHouse.mintNFT(metadata: <-metadata)        // Create NFT

            // Create Auctions
            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)
            // Add Auction
            let aid = auction.auctionID             
            let oldAuction <- self.currentAuctions.insert(key: aid, <- auction)
            destroy oldAuction
        }

        // Creates an auction for a NFT.
        pub fun createAuction(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool,
            extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64)
        {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
                DAAM.copyright[nft.metadata.mid] != DAAM.CopyrightStatus.FRAUD : "This submission has been flaged for Copyright Issues."
                DAAM.copyright[nft.metadata.mid] != DAAM.CopyrightStatus.CLAIM : "This submission has been flaged for a Copyright Claim." 
            }

            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: false)
            // Add Auction
            let aid = auction.auctionID             
            let oldAuction <- self.currentAuctions.insert(key: aid, <- auction)
            destroy oldAuction
            
            log("Auction Created. Start: ".concat(start.toString()) )
            emit AuctionCreated(auctionID: aid)
        }

        // Closes all Auctions that have Ended". All funds and items are delegated accordingly.
        pub fun closeAuctions() {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
            }

            for act in self.currentAuctions.keys {                
                let current_status = self.currentAuctions[act]?.updateStatus() // status value may be changed with verifyReservePrive by seriesMinter
                if current_status == false {
                    let auctionID = self.currentAuctions[act]?.auctionID!
                    log("Closing Token ID: ")
                    if self.currentAuctions[act]?.auctionNFT != nil { // winner already collected
                        self.currentAuctions[act]?.verifyReservePrice()! // does it meet the reserve price?
                    }

                    if self.currentAuctions[act]?.status == true { // Series Minter is minting another Metadata to NFT restarting.
                        continue
                    }  

                    let auction <- self.currentAuctions.remove(key:auctionID)!   // No Series minting or last...
                    destroy auction                                            // end auction.

                    log("Auction Closed: ".concat(auctionID.toString()) )
                    emit AuctionClosed(auctionID: auctionID)
                }
            }
        }

        pub fun item(_ aid: UInt64): &Auction { // item(Token ID) return a reference of the auctionID Auction
            pre { self.currentAuctions.containsKey(aid) }
            return &self.currentAuctions[aid] as &Auction
        }

        pub fun endReprints(auctionID: UInt64) {
            pre {
                self.currentAuctions.containsKey(auctionID)     : "AuctionID does not exist"
                self.currentAuctions[auctionID]?.reprintSeries! : "Reprint is already set to Off."
            }
            self.currentAuctions[auctionID]?.endReprints()
        }

        pub fun getAuctions(): [UInt64] { return self.currentAuctions.keys } // return all auctions by User

        destroy() { destroy self.currentAuctions }
    }
/************************************************************************/
    pub resource Auction {
        access(contract) var status: Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        pub var auctionID   : UInt64  // Auction ID number. Note: Series auctions keep the same number. 
        pub let mid         : UInt64  // collect Metadata ID
        pub var start       : UFix64  // timestamp
        pub let origLength  : UFix64  // original length of auction, needed to reset if Series
        pub var length      : UFix64  // post{!isExtended && length == before(length)}
        pub let isExtended  : Bool    // true = Auction extends with every bid.
        pub let extendedTime: UFix64  // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
        pub var leader      : Address? // leading bidder
        pub var minBid      : UFix64? // minimum bid
        pub let increment   : {Bool : UFix64} // true = is amount, false = is percentage *Note 1.0 = 100%
        pub let startingBid : UFix64? // starting bid
        pub let reserve     : UFix64  // the reserve. must be sold at min price.
        pub let buyNow      : UFix64  // buy now price
        pub var reprintSeries: Bool   // Active Series Minter (if series)
        pub var auctionLog   : {Address: UFix64} // {Bidders, Amount} // Log of the Auction
        pub var auctionNFT  : @DAAM.NFT? // Store NFT for auction
        priv var auctionVault: @FungibleToken.Vault // Vault, All funds are stored.
    
        init(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
          incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool) {
            pre {
                start >= getCurrentBlock().timestamp : "Time has already past."
                length > 1.0 as UFix64               : "Minimum is 1 hour"  // 1 hour = 3600  // TODO rest 1.0 to 3599.99
                buyNow > reserve || buyNow == 0.0    : "The BuyNow option must be greater then the Reserve."
                startingBid != 0.0 : "You can not have a Starting Bid of zero."
                isExtended && extendedTime >= 60.0 || !isExtended && extendedTime == 0.0 : "Extended Time setting are incorrect. The minimim is 1 min."
                reprintSeries && nft.metadata.series != 1 || !reprintSeries : "This can not be reprinted."
            }
            
            // Manage minBid
            if startingBid == nil { // When starting Bid, Direct Purchase
                if buyNow == 0.0 { panic("Direct Purchase, BuyItNow requires value") } // is Direct Purchase, BuyItNow requires value
                if isExtended    { panic("Direct Purchase, can not be an Extended Auction.") }
            } else if reserve < startingBid! { panic("The Reserve must be greater then your Starting Bid") }
            
            // Manage incrementByPrice
            if incrementByPrice == false && incrementAmount < 0.025 { panic("The minimum increment is 2.5%.")   }
            if incrementByPrice == false && incrementAmount > 0.05  { panic("The maximum increment is 5%.")     }
            if incrementByPrice == true  && incrementAmount < 1.0   { panic("The minimum increment is 1 FUSD.") }

            AuctionHouse.auctionCounter = AuctionHouse.auctionCounter + 1 // increment Auction Counter
            self.status = nil // nil = auction not started, true = auction ongoing, false = auction ended
            self.auctionID = AuctionHouse.auctionCounter // Auction uinque ID number
            self.mid = nft.metadata.mid
            self.start = start        // When auction start
            self.length = length      // Length of auction
            self.origLength = length  // If length is reset (extneded auction), a new reprint can reset the original length
            self.leader = nil         // Current leader, when nil = no leader
            self.minBid = startingBid // when nil= Direct Purchase, buyNow Must have a value
            self.isExtended = isExtended // isExtended status
            self.extendedTime = (isExtended) ? extendedTime : 0.0 as UFix64
            self.increment = {incrementByPrice : incrementAmount}
            
            self.startingBid = startingBid
            self.reserve = reserve
            self.buyNow = buyNow
            // if last in series don't reprint.
            self.reprintSeries = nft.metadata.series == nft.metadata.counter ? false : reprintSeries

            self.auctionLog = {} // Maintain record of FUSD // {Address : FUSD}
            self.auctionVault <- FUSD.createEmptyVault() // ALL FUSD is stored

            self.auctionNFT <- nft // NFT Storage durning auction

            log("Auction Initialized: ".concat(self.auctionID.toString()) )
            emit AuctionCreated(auctionID: self.auctionID)
        }

        // Makes Bid, Bids are deposited into vault
        pub fun depositToBid(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {         
                self.minBid != nil                    : "No Bidding. Direct Purchase Only."     
                self.updateStatus() == true           : "Auction is not in progress."
                self.validateBid(bidder: bidder.address, balance: amount.balance) : "You have made an invalid Bid."
                self.leader != bidder.address         : "You are already lead bidder."
                self.owner?.address != bidder.address : "You can not bid in your own auction."
            }
            post { self.verifyAuctionLog() }

            log("self.minBid: ".concat(self.minBid!.toString()) )

            self.leader = bidder.address      // set new leader
            self.updateAuctionLog(amount.balance)     
            self.incrementminBid()            // increment accordingly
            self.auctionVault.deposit(from: <- amount)  // put FUSD into Vault
            self.extendAuction()  // If extendend auction... extend

            log("Balance: ".concat(self.auctionLog[self.leader!]!.toString()) )
            log("Min Bid: ".concat(self.minBid!.toString()) )

            log("Bid Accepted")
            emit BidMade(auctionID: self.auctionID, bidder:self.leader! )
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
        // nil = auction not started or no bid, true = started (with bid), false = auction ended
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
                self.status = nil
            } else {
                log("Status: Auction Ongoing")
                self.status = true
            }

            return self.status
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
                self.updateStatus() == false  : "Auction has not Ended."
                //self.minBid != nil
                self.leader == bidder.address : "You do not have access to the selected Auction"
            }
            self.verifyReservePrice() // ... Reserve Price verification is the next step.
        }

        access(contract) fun verifyReservePrice() {
            pre  { self.updateStatus() == false   : "Auction still in progress" }
            post { self.verifyAuctionLog() }

            var receiver = self.leader
            var pass     = false

            log("Auction Log: ".concat(self.auctionLog.length.toString()) )

            if receiver != nil {
                // Does the leader meet the reserve price?
                if self.auctionLog[self.leader!]! >= self.reserve {
                    pass = true
                }
            }

            if pass {
                // remove leader from log before returnFunds()!!
                self.auctionLog.remove(key: self.leader!)!
                self.returnFunds()
                self.royality()
                log("Item: Won")
                emit AuctionCollected(winner: self.leader!, auctionID: self.auctionID) // Auction Ended, but Item not delivered yet.
            } else {                
                //receiver = self.creator
                receiver = self.owner?.address
                self.returnFunds()
                log("Item: Returned")
                emit AuctionReturned(auctionID: self.auctionID)    
            }
            log("receiver: ".concat(receiver?.toString()!) )   
            let collectionRef = getAccount(receiver!).getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath).borrow()!
            // NFT Deposot Must be LAST !!! *except for seriesMinter
            let nft <- self.auctionNFT <- nil            
            collectionRef.deposit(token: <- nft!)

            if pass { 
                // possible re-auction Series Minter
                self.seriesMinter() // Note must be last after transer of NFT
            }
        }

        priv fun verifyAmount(bidder: Address, amount: UFix64): Bool {
            log("self.buyNow: ".concat(self.buyNow.toString()) )
            
            var total = amount
            log("total: ".concat(total.toString()) )
            if self.auctionLog[bidder] != nil {
                total = total + self.auctionLog[bidder]! as UFix64
            }
            log("total: ".concat(total.toString()) )
            return self.buyNow == total
        }

        priv fun updateAuctionLog(_ amount: UFix64) {
            if !self.auctionLog.containsKey(self.leader!) { // First bid by user
                self.auctionLog.insert(key: self.leader!, amount)
            } else {
                let total = self.auctionLog[self.leader!]! + amount
                self.auctionLog[self.leader!] = total
            }
        }          

        pub fun buyItNow(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {
                self.updateStatus() != false  : "Auction has Ended."
                self.buyNow != 0.0 : "Buy It Now option is not available."
                self.verifyAmount(bidder: bidder.address, amount: amount.balance) : "Wrong Amount."
                // Must be after the above line.
                self.buyItNowStatus() : "Buy It Now option has expired."
            }
            post { self.verifyAuctionLog() }

            self.status = false  // ends the auction
            self.length = 0.0 as UFix64  // set length to 0; double end auction
            self.leader = bidder.address                // set new leader

            self.updateAuctionLog(amount.balance)
            self.auctionVault.deposit(from: <- amount)  // depsoit into Auction Vault

            log("Buy It Now")
            emit BuyItNow(winner: self.leader!, auction: self.auctionID, amount: self.buyNow)                         // pay royalities

            self.winnerCollect(bidder: bidder)
        }    

        // returns BuyItNowStaus, true = active, false = inactive
        pub fun buyItNowStatus(): Bool {
            pre {
                self.buyNow != 0.0 : "No Buy It Now option for this auction."
                self.updateStatus() != false : "Auction is over or invalid."
            }
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
        pub fun cancelAuction(auctioneer: AuthAccount)/* : @NonFungibleToken.NFT*/ {
            pre {
                self.updateStatus() == nil || true         : "Too late to cancel Auction."
                self.auctionLog.length == 0                : "You already have a bid. Too late to Cancel."
                self.owner?.address! == auctioneer.address : "You are not the auctioneer."
            }
            
            self.status = false
            self.length = 0.0 as UFix64

            log("Auction Cancelled: ".concat(self.auctionID.toString()) )
            emit AuctionCancelled(auctionID: self.auctionID)
        }

        priv fun extendAuction() { // extends auction by extendedTime
            if !self.isExtended { return } // not Extended Auction
            let end = self.start + self.length // Get end time by adding Start time + Length of Auction
            let new_length = (end - getCurrentBlock().timestamp) + self.extendedTime // (Time Left) + extendend Time
            if new_length > end { self.length = new_length } // if new_length is greater then the original end, update
        }

        pub fun getStatus(): Bool? { // gets Auction status: nil=not started, true=ongoing, false=ended
            return self.updateStatus()
        }

        pub fun timeLeft(): UFix64? { // returns time left, nil = not started yet.
            if self.length == 0.0 {
                return 0.0 as UFix64
            } // Extended Auction ended.

            let timeNow = getCurrentBlock().timestamp
            log("TimeNow: ".concat(timeNow.toString()) )
            if timeNow < self.start { return nil }

            let end = self.start + self.length
            log("End: ".concat(end.toString()) )

            
            if timeNow >= self.start && timeNow < end {
                let timeleft = end - timeNow
                return timeleft
            }
            return 0.0 as UFix64
        }

        // Royality rates are gathered from the NFTs metadata and funds are proportioned accordingly. 
        priv fun royality()
        {
            post { self.auctionVault.balance == 0.0 : "Royality Error: ".concat(self.auctionVault.balance.toString() ) } // The Vault should always end empty

            if self.auctionVault.balance == 0.0 { return } // No need to run, already processed.

            let price = self.auctionVault.balance   // get price of NFT
            let metadataRef = &self.auctionNFT?.metadata! as &DAAM.Metadata // get NFT Metadata Reference
            let tokenID = self.auctionNFT?.id!
            let royality = self.getRoyality()       // get all royalities percentages
            
            let agencyPercentage  = royality[DAAM.agency]!          // extract Agency percentage
            let creatorPercentage = royality[metadataRef.creator]!  // extract creators percentage using Metadata Reference
            
            let agencyRoyality  = DAAM.newNFTs.contains(tokenID) ? 0.20 : agencyPercentage  // If 'new' use default 15% for Agency.  First Sale Only.
            let creatorRoyality = DAAM.newNFTs.contains(tokenID) ? 0.80 : creatorPercentage // If 'new' use default 85% for Creator. First Sale Only.
            
            let agencyCut  <-! self.auctionVault.withdraw(amount: price * agencyRoyality)  // Calculate Agency FUSD share
            let creatorCut <-! self.auctionVault.withdraw(amount: price * creatorRoyality) // Calculate Creator FUSD share
            // get FUSD Receivers for Agency & Creator

            // If 1st sale is 'new' remove from 'new list'
            if DAAM.newNFTs.contains(tokenID) {
                AuctionHouse.notNew(tokenID: tokenID)
            } else { // else no longer "new", Seller is onjly need on reSales.
                let seller = self.owner?.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)!.borrow()!
                let sellerPercentage = 1.0 as UFix64 - (agencyPercentage + creatorPercentage)
                let sellerCut <-! self.auctionVault.withdraw(amount: price * sellerPercentage)
                seller.deposit(from: <-sellerCut ) // Agency & Creator have already taken their cut
            }
            
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

        // return royality information
        priv fun getRoyality(): {Address : UFix64} {
            let royality = self.auctionNFT?.royality!
            return royality 
        }
        
        // resets all variables that need to be reset
        priv fun resetAuction() {
            //pre { self.auctionVault.balance == 0.0 : "Internal Error: Serial Minter" }
            log("Reset Auction")
            log(self.reprintSeries)
            if !self.reprintSeries { return } // if reprint is set to off (false) return   
            self.leader = nil
            self.start = getCurrentBlock().timestamp
            self.length = self.origLength
            self.auctionLog = {}
            self.minBid = self.startingBid
            self.status = true       
            log("Reset: Variables")
        }

        priv fun seriesMinter() {
            pre { self.auctionVault.balance == 0.0 : "Internal Error: Serial Minter" }
            if !self.reprintSeries { return } // if reprint is set to off (false) return
            let metadataGen = AuctionHouse.metadataGen[self.mid]!.borrow()!
            let metadataRef = metadataGen.getMetadataRef(mid: self.mid)
            let creator = metadataRef.creator
            if creator != self.owner?.address! { return }  // verify owner is creator
            let metadata <- metadataGen.generateMetadata(mid: self.mid)
            let old <- self.auctionNFT <- AuctionHouse.mintNFT(metadata: <-metadata)
            destroy old
            self.resetAuction()
        } 

        access(contract) fun endReprints() {
           pre {
                self.reprintSeries : "Reprints is already off."
                self.auctionNFT?.metadata!.creator == self.owner?.address! : "You are not the Creator of this NFT"
                //self.auctionNFT.metadata.series != 1 : "This is a 1-Shot NFT" // not reachable
           }
           self.reprintSeries = false
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
        let minter = self.account.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)!
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
        self.auctionCounter = 0
        self.auctionStoragePath = /storage/DAAM_Auction
        self.auctionPublicPath  = /public/DAAM_Auction
    }
}
