// auction.cdc
// by Ami Rajpal, 2021 // DAAM Agency

import FungibleToken    from 0xee82856bf20e2aa6
import FUSD             from 0x192440c99cb17282
import DAAM             from 0xfd43f9148d4b725d
import NonFungibleToken from 0xf8d6e0586b0a20c7

pub contract AuctionHouse {
    // Events
    //pub event AuctionInitialized() //
    pub event AuctionCreated(auctionID: UInt64) // Auction has been created. 
    pub event AuctionClosed(auctionID: UInt64)  // Auction has been finalized and has been removed.
    pub event AuctionCancelled(auctionID: UInt64) // Auction has been cancelled
    pub event ItemReturned(auctionID: UInt64)     // Auction has ended and the Reserve price was not meet.
    pub event BidMade(auctionID: UInt64, bidder: Address ) // Bid has been made on an Item
    pub event BidWithdrawn(bidder: Address)                // Bidder has withdrawn their bid
    pub event ItemWon(winner: Address, auctionID: UInt64)  // Item has been Won in an auction
    pub event BuyItNow(winner: Address, auction: UInt64, amount: UFix64) // Buy It Now has been completed
    pub event FundsReturned() // Funds have been returned accordingly
    // Path for Auction Wallet
    pub let auctionStoragePath: StoragePath
    pub let auctionPublicPath : PublicPath
    // Variables
    // Note: Do not confuse (Token)ID with MID
    access(contract) var metadataGen : { UInt64 : Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}> } // { MID : Capability<&DAAM.MetadataGenerator> }
    access(contract) var auctionCounter : UInt64 // Incremental counter used for AID (Auction ID)

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
            self.titleholder = auctioneer.address // Owner of the address
            self.currentAuctions <- {}            // Auction Resources are stored here. The Auctions themselves.
        }

        // createOriginalAuction: An Original Auction is defined as a newly minted NFT.
        // MetadataGenerator: Reference to Metadata
        // mid: DAAM Metadata ID
        // start: Enter UNIX Flow Blockchain Time
        // length: Length of auction
        // isExtended: if the auction lenght is to be an Extended Auction
        // extendedTime: The amount of time the extension is to be.
        // incrementByPrice: increment by fixed amount or percentage. True = fixed amount, False = Percentage
        // incrementAmount: the increment value. when incrementByPrice is true, the minimum bid is increased by this amount.
        //                  when False, the minimin bid is increased by that Percentage. Note: 1.0 = 100%
        // startingBid: the initial price. May not be 0.0
        // reserve: The minimum price that must be meet
        // buyNow: To amount to purchase an item directly. Note: 0.0 = OFF
        // reprintSeries: to duplicate the current auction, with a reprint (Next Mint os Series)
        // *** new is defines as "never sold", age is not a consideration. ***
        pub fun createOriginalAuction(metadataGenerator: Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>, mid: UInt64, start: UFix64, length: UFix64,
        isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
        {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
                metadataGenerator != nil : "There is no Metadata."
                DAAM.getCopyright(mid: mid) != DAAM.CopyrightStatus.FRAUD : "This submission has been flaged for Copyright Issues."
                DAAM.getCopyright(mid: mid) != DAAM.CopyrightStatus.CLAIM : "This submission has been flaged for a Copyright Claim." 
            }
            log("metadataGenerator")
            log(metadataGenerator)

            let metadataRef = metadataGenerator.borrow()! as &DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint} // Get MetadataHolder
            let metadata <-! metadataRef.generateMetadata(mid: mid)      // Create MetadataHolder
            let nft <- AuctionHouse.mintNFT(metadata: <-metadata)        // Create NFT

            AuctionHouse.metadataGen.insert(key: mid, metadataGenerator) // add access to Creators' Metadata


            // Create Auctions
            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)
            // Add Auction
            let aid = auction.auctionID // Auction ID
            let oldAuction <- self.currentAuctions.insert(key: aid, <- auction) // Store Auction
            destroy oldAuction // destroy placeholder
        }

        // Creates an auction for a NFT as opposed to Metadata. An existing NFT.
        // same arguments as createOriginalAuction except for reprintSeries
        pub fun createAuction(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool,
            extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64)
        {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction" 
                DAAM.getCopyright(mid: nft.metadata.mid) != DAAM.CopyrightStatus.FRAUD : "This submission has been flaged for Copyright Issues."
                DAAM.getCopyright(mid: nft.metadata.mid) != DAAM.CopyrightStatus.CLAIM : "This submission has been flaged for a Copyright Claim." 
            }

            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: false)
            // Add Auction
            let aid = auction.auctionID // Auction ID
            let oldAuction <- self.currentAuctions.insert(key: aid, <- auction) // Store Auction
            destroy oldAuction // destroy placeholder
            
            log("Auction Created. Start: ".concat(start.toString()) )
            emit AuctionCreated(auctionID: aid)
        }

        // Resolves all Auctions. Closes ones that have been ended or restarts them due to being a reprintSeries auctions.
        // This allows the auctioneer to close auctions to auctions that have ended, returning funds and appropriating items accordingly
        // even in instances where the Winner has not claimed their item.
        pub fun closeAuctions() {
            pre {
                self.titleholder == self.owner?.address! : "You are not the owner of this Auction"
            }

            for act in self.currentAuctions.keys {                
                let current_status = self.currentAuctions[act]?.updateStatus() // status may be changed in verifyReservePrive() by seriesMinter()
                if current_status == false { // Check to see if auction has ended. A false value.
                    let auctionID = self.currentAuctions[act]?.auctionID! // get AID
                    log("Closing Token ID: ")
                    if self.currentAuctions[act]?.auctionNFT != nil { // Winner has already collected
                        self.currentAuctions[act]?.verifyReservePrice()! // Winner has not claimed their item. Verify they have meet the reserve price?
                    }

                    if self.currentAuctions[act]?.status == true { // Series Minter is minting another Metadata to NFT. Auction Restarting.
                        continue
                    }  

                    let auction <- self.currentAuctions.remove(key:auctionID)!   // No Series minting or last mint
                    destroy auction                                              // end auction.

                    log("Auction Closed: ".concat(auctionID.toString()) )
                    emit AuctionClosed(auctionID: auctionID)
                }
            }
        }

        // item(Auction ID) return a reference of the auctionID Auction
        pub fun item(_ aid: UInt64): &Auction { 
            pre { self.currentAuctions.containsKey(aid) }
            return &self.currentAuctions[aid] as &Auction
        }

        pub fun endReprints(auctionID: UInt64) { // Toggles the reprint to OFF. Note: This is not a toggle
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
        priv var height     : UInt64?      // Stores the final block height made by the final bid only.
        pub var auctionID   : UInt64       // Auction ID number. Note: Series auctions keep the same number. 
        pub let mid         : UInt64       // collect Metadata ID
        pub var start       : UFix64       // timestamp
        priv let origLength   : UFix64   // original length of auction, needed to reset if Series
        pub var length        : UFix64   // post{!isExtended && length == before(length)}
        pub let isExtended    : Bool     // true = Auction extends with every bid.
        pub let extendedTime  : UFix64   // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
        pub var leader        : Address? // leading bidder
        pub var minBid        : UFix64?  // minimum bid
        priv let increment    : {Bool : UFix64} // true = is amount, false = is percentage *Note 1.0 = 100%
        pub let startingBid   : UFix64?  // the starting bid od an auction. Nil = No Bidding. Direct Purchase
        pub let reserve       : UFix64   // the reserve. must be sold at min price.
        pub let buyNow        : UFix64   // buy now price
        pub var reprintSeries : Bool     // Active Series Minter (if series)
        pub var auctionLog    : {Address: UFix64}    // {Bidders, Amount} // Log of the Auction
        access(contract) var auctionNFT : @DAAM.NFT? // Store NFT for auction
        priv var auctionVault : @FungibleToken.Vault // Vault, All funds are stored.
    
        // Auction: A resource containg the auction itself.
        // start: Enter UNIX Flow Blockchain Time
        // length: Length of auction
        // isExtended: if the auction lenght is to be an Extended Auction
        // extendedTime: The amount of time the extension is to be.
        // incrementByPrice: increment by fixed amount or percentage. True = fixed amount, False = Percentage
        // incrementAmount: the increment value. when incrementByPrice is true, the minimum bid is increased by this amount.
        //                  when False, the minimin bid is increased by that Percentage. Note: 1.0 = 100%
        // startingBid: the initial price. May not be 0.0
        // reserve: The minimum price that must be meet
        // buyNow: To amount to purchase an item directly. Note: 0.0 = OFF
        // reprintSeries: to duplicate the current auction, with a reprint (Next Mint os Series)
        // *** new is defines as "never sold", age is not a consideration. ***
        init(nft: @DAAM.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
          incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool) {
            pre {
                start >= getCurrentBlock().timestamp : "Time has already past."
                length > 1.0 as UFix64               : "Minimum is 1 min" // TODO Replace 1 with 60
                buyNow > reserve || buyNow == 0.0    : "The BuyNow option must be greater then the Reserve."
                startingBid != 0.0 : "You can not have a Starting Bid of zero."
                isExtended && extendedTime >= 20.0 || !isExtended && extendedTime == 0.0 : "Extended Time setting are incorrect. The minimim is 20 seconds."
                reprintSeries && nft.metadata.series != 1 || !reprintSeries : "This can not be reprinted."
                startingBid == nil && buyNow != 0.0 || startingBid != nil : "Direct Purchase requires BuyItNow amount"
            }
            if startingBid != nil { // Verify starting bid is lower then the reserve price
                if reserve < startingBid! { panic("The Reserve must be greater then your Starting Bid") }
            }            
            // Manage incrementByPrice
            if incrementByPrice == false && incrementAmount < 0.01  { panic("The minimum increment is 1.0%.")   }
            if incrementByPrice == false && incrementAmount > 0.05  { panic("The maximum increment is 5.0%.")     }
            if incrementByPrice == true  && incrementAmount < 1.0   { panic("The minimum increment is 1 FUSD.") }

            AuctionHouse.auctionCounter = AuctionHouse.auctionCounter + 1 // increment Auction Counter
            self.status = nil // nil = auction not started, true = auction ongoing, false = auction ended
            self.height = nil  // when auction is ended does it get a value
            self.auctionID = AuctionHouse.auctionCounter // Auction uinque ID number
            self.mid = nft.metadata.mid // Metadata ID
            self.start = start        // When auction start
            self.length = length      // Length of auction
            self.origLength = length  // If length is reset (extneded auction), a new reprint can reset the original length
            self.leader = nil         // Current leader, when nil = no leader
            self.minBid = startingBid // when nil= Direct Purchase, buyNow Must have a value
            self.isExtended = isExtended // isExtended status
            self.extendedTime = (isExtended) ? extendedTime : 0.0 as UFix64  // Store extended time
            self.increment = {incrementByPrice : incrementAmount} // Store increment 
            
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
                self.height == nil || getCurrentBlock().height < self.height! : "You bid was too late"
            }
            post { self.verifyAuctionLog() } // Verify Funds

            log("self.minBid: ".concat(self.minBid!.toString()) )

            self.leader = bidder.address           // set new leader
            self.updateAuctionLog(amount.balance)  // update logs with new balance
            self.incrementminBid()                 // increment accordingly
            self.auctionVault.deposit(from: <- amount)  // deposit FUSD into Vault
            self.extendAuction()                        // extendend auction if applicable

            log("Balance: ".concat(self.auctionLog[self.leader!]!.toString()) )
            log("Min Bid: ".concat(self.minBid!.toString()) )
            log("Bid Accepted")
            emit BidMade(auctionID: self.auctionID, bidder:self.leader! )
        }

        // validateBid: Verifies the amount given meets the minimum bid.
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
            // Verify bidders' total amount is meets the minimum bid
            if (balance + self.auctionLog[bidder]!) >= self.minBid! {
                return true
            }
            // retutning false, reserve price not meet
            log("Bid Deposit too low.")
            return false
        }

        // increments minimum bid by fixed amount or percentage based on incrementByPrice
        priv fun incrementminBid() {
            let bid = self.auctionLog[self.leader!]! // get current bid
            if self.increment[false] != nil {        // check if increment is by percentage
                self.minBid = bid + (bid * self.increment[false]!) // increase minimum bid by percentage
            } else { // price incrememt by fixed amount
                self.minBid = bid + self.increment[true]!
            }
        }

        // Returns and Updates the current status of the Auction
        // nil = auction not started, true = started, false = auction ended
        access(contract) fun updateStatus(): Bool? {
            if self.status == false {  // false = Auction has already Ended
                log("Status: Auction Previously Ended")
                return false
            }
            // First time Auction has been flaged as Ended
            let auction_time = self.timeLeft() // a return of 0.0 signals the auction has ended.
            if auction_time == 0.0 {
                self.status = false                    // set auction to End (false)
                self.height = getCurrentBlock().height // get height for bids at enf of auction.
                log("Status: Time Limit Reached & Auction Ended")
                return false
            }

            if auction_time == nil { // nil = Auction has not yet started
                log("Status: Not Started")
                self.status = nil
            } else {
                log("Status: Auction Ongoing")
                self.status = true // true = Auction is ongoing
            }

            return self.status
        }

        // Allows bidder to withdraw their bid as long as they are not the lead bidder.
        pub fun withdrawBid(bidder: AuthAccount): @FungibleToken.Vault {
            pre {
                self.leader! != bidder.address : "You have the Winning Bid. You can not withdraw."
                self.updateStatus() != false   : "Auction has Ended."
                self.auctionLog.containsKey(bidder.address) : "You have not made a Bid"
                self.minBid != nil : "This is a Buy It Now only purchase."
                self.verifyAuctionLog() : "Internal Error!!"
            }
            post { self.verifyAuctionLog() }

            let balance = self.auctionLog[bidder.address]! // Get balance from log
            self.auctionLog.remove(key: bidder.address)!   // Remove from log
            let amount <- self.auctionVault.withdraw(amount: balance)! // Withdraw balance from Vault
            log("Bid Withdrawn")
            emit BidWithdrawn(bidder: bidder.address)    
            return <- amount  // return bidders deposit amount
        }

        // Winner can 'Claim' an item. Reserve price must be meet, otherwise returned to auctioneer
        pub fun winnerCollect(bidder: AuthAccount) {
            pre{
                self.updateStatus() == false  : "Auction has not Ended."
                self.leader == bidder.address : "You do not have access to the selected Auction"
            }
            self.verifyReservePrice() // Verify Reserve price is met
        }

        // This is a key function where are all the action happens.
        // Verifies the Reserve Price is met. 
        // Calls royality() & ReturnFunds() and manages all royalities and funds are returned
        // Sends the item (NFT)
        access(contract) fun verifyReservePrice() {
            pre  { self.updateStatus() == false   : "Auction still in progress" }
            post { self.verifyAuctionLog() } // Verify funds calcuate

            var receiver = self.leader // receiver of the item
            var pass     = false       // false till reserve price is verified

            log("Auction Log Length: ".concat(self.auctionLog.length.toString()) )

            if receiver != nil {
                // Does the leader meet the reserve price?
                if self.auctionLog[self.leader!]! >= self.reserve {
                    pass = true
                }
            }

            if pass { // leader meet the reserve price
                // remove leader from log before returnFunds()!!
                self.auctionLog.remove(key: self.leader!)!
                self.returnFunds()  // return funds to all bidders
                self.royality()     // pay royality
                log("Item: Won")
                emit ItemWon(winner: self.leader!, auctionID: self.auctionID) // Auction Ended, but Item not delivered yet.
            } else {                
                receiver = self.owner?.address // set receiver from leader to auctioneer
                self.returnFunds()             // return funds to all bidders
                log("Item: Returned")
                emit ItemReturned(auctionID: self.auctionID)    
            }
            log("receiver: ".concat(receiver?.toString()!) )   
            let collectionRef = getAccount(receiver!).getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath).borrow()!
            // NFT Deposot Must be LAST !!! *except for seriesMinter
            let nft <- self.auctionNFT <- nil     // remove nft   
            collectionRef.deposit(token: <- nft!) // deposit nft

            if pass { // possible re-auction Series Minter                
                self.seriesMinter() // Note must be last after transer of NFT
            }
        }

        // Verifies amount is equal to the buyNow amount. If not returns false
        priv fun verifyBuyNowAmount(bidder: Address, amount: UFix64): Bool {
            log("self.buyNow: ".concat(self.buyNow.toString()) )
            
            var total = amount
            log("total: ".concat(total.toString()) )
            if self.auctionLog[bidder] != nil { 
                total = total + self.auctionLog[bidder]! as UFix64 // get bidders' total deposit
            }
            log("total: ".concat(total.toString()) )
            return self.buyNow == total // compare bidders' total deposit to buyNow
        }

        // Record total amount of FUSD a bidder has deposited. Manages Log of that total.
        priv fun updateAuctionLog(_ amount: UFix64) {
            if !self.auctionLog.containsKey(self.leader!) {        // First bid by user
                self.auctionLog.insert(key: self.leader!, amount)  // append log for new bidder and log amount
            } else {
                let total = self.auctionLog[self.leader!]! + amount // get new total deposit of bidder
                self.auctionLog[self.leader!] = total               // append log with new amount
            }
        }          

        // To purchase the item directly. 
        pub fun buyItNow(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {
                self.updateStatus() != false  : "Auction has Ended."
                self.buyNow != 0.0 : "Buy It Now option is not available."
                self.verifyBuyNowAmount(bidder: bidder.address, amount: amount.balance) : "Wrong Amount."
                // Must be after the above line.
                self.buyItNowStatus() : "Buy It Now option has expired."
            }
            post { self.verifyAuctionLog() } // verify log

            self.status = false          // ends the auction
            self.length = 0.0 as UFix64  // set length to 0; double end auction
            self.leader = bidder.address // set new leader

            self.updateAuctionLog(amount.balance)       // update auction log with new leader
            self.auctionVault.deposit(from: <- amount)  // depsoit into Auction Vault

            log("Buy It Now")
            emit BuyItNow(winner: self.leader!, auction: self.auctionID, amount: self.buyNow)                         // pay royalities

            self.winnerCollect(bidder: bidder) // Will receive NFT if reserve price is met
        }    

        // returns BuyItNowStaus, true = active, false = inactive
        pub fun buyItNowStatus(): Bool {
            pre {
                self.buyNow != 0.0 : "No Buy It Now option for this auction."
                self.updateStatus() != false : "Auction is over or invalid."
            }
            if self.leader != nil {
                return self.buyNow > self.auctionLog[self.leader!]! // return 'Buy it Now' price to the current bid
            }
            return true
        }

        // Return all funds in auction log to bidder
        // Note: leader is typically removed from log before called.
        priv fun returnFunds() {
            post { self.auctionLog.length == 0 } // Verify auction log is empty

            for bidder in self.auctionLog.keys {
                // get FUSD Wallet capability
                let bidderRef =  getAccount(bidder).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
                let amount <- self.auctionVault.withdraw(amount: self.auctionLog[bidder]!)  // Withdraw amount
                bidderRef.deposit(from: <- amount)  // Deposit amount to bidder
            }

            log("Funds Returned")
            emit FundsReturned()
        }

        // Auctions can be cancelled if they have no bids. 
        pub fun cancelAuction(auctioneer: AuthAccount) {
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

        // Checks for Extended Auction and extends auction accordingly by extendedTime
        priv fun extendAuction() { 
            if !self.isExtended { return }     // not Extended Auction return
            let end = self.start + self.length // Get end time
            let new_length = (end - getCurrentBlock().timestamp) + self.extendedTime // get new length
            if new_length > end { self.length = new_length } // if new_length is greater then the original end, update
        }

        pub fun getStatus(): Bool? { // gets Auction status: nil = not started, true = ongoing, false = ended
            return self.updateStatus()
        }

        pub fun itemInfo(): DAAM.Metadata? { // returns the metadata of the item NFT.
            return self.auctionNFT?.metadata
        }

        pub fun timeLeft(): UFix64? { // returns time left, nil = not started yet.
            if self.length == 0.0 {
                return 0.0 as UFix64
            } // Extended Auction ended.

            let timeNow = getCurrentBlock().timestamp
            log("TimeNow: ".concat(timeNow.toString()) )
            if timeNow < self.start { return nil } // Auction has not started

            let end = self.start + self.length     // get end time of auction
            log("End: ".concat(end.toString()) )

            
            if timeNow >= self.start && timeNow < end { // if time is durning auction
                let timeleft = end - timeNow            // calculate time left
                return timeleft                         // return time left
            }
            return 0.0 as UFix64 // return no time left
        }

        // Royality rates are gathered from the NFTs metadata and funds are proportioned accordingly. 
        priv fun royality()
        {
            post { self.auctionVault.balance == 0.0 : "Royality Error: ".concat(self.auctionVault.balance.toString() ) } // The Vault should always end empty

            if self.auctionVault.balance == 0.0 { return } // No need to run, already processed.

            let price = self.auctionVault.balance                           // get price of NFT
            let metadataRef = &self.auctionNFT?.metadata! as &DAAM.Metadata // get NFT Metadata Reference
            let tokenID = self.auctionNFT?.id!                              // get TokenID
            let royality = self.getRoyality()                               // get all royalities percentages
            
            let agencyPercentage  = royality[DAAM.agency]!          // extract Agency percentage
            let creatorPercentage = royality[metadataRef.creator]!  // extract creators percentage using Metadata Reference
            
            let agencyRoyality  = DAAM.isNFTNew(id: tokenID) ? 0.20 : agencyPercentage  // If 'new' use default 15% for Agency.  First Sale Only.
            let creatorRoyality = DAAM.isNFTNew(id: tokenID) ? 0.80 : creatorPercentage // If 'new' use default 85% for Creator. First Sale Only.
            
            let agencyCut  <-! self.auctionVault.withdraw(amount: price * agencyRoyality)  // Calculate Agency FUSD share
            let creatorCut <-! self.auctionVault.withdraw(amount: price * creatorRoyality) // Calculate Creator FUSD share
            // get FUSD Receivers for Agency & Creator

            // If 1st sale is 'new' remove from 'new list'
            if DAAM.isNFTNew(id: tokenID) {
                AuctionHouse.notNew(tokenID: tokenID)
            } else { // else no longer "new", Seller is only need on re-sales.
                let seller = self.owner?.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)!.borrow()! // get Seller FUSD Wallet Capability
                let sellerPercentage = 1.0 as UFix64 - (agencyPercentage + creatorPercentage)  // Calculate Percentage left over
                let sellerCut <-! self.auctionVault.withdraw(amount: price * sellerPercentage) // Calcuate actual amount
                seller.deposit(from: <-sellerCut ) // deposit amount
            }
            
            let agencyPay  = getAccount(DAAM.agency).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
            let creatorPay = getAccount(metadataRef.creator).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
            
            agencyPay.deposit(from: <-agencyCut)   // Deposit Agency Cut
            creatorPay.deposit(from: <-creatorCut) // Deposit Creators' Cut
        }

        // Comapres Log to Vault. Makes sure Funds match. Should always be true!
        priv fun verifyAuctionLog(): Bool {
            var total = 0.0
            for amount in self.auctionLog.keys {
                total = total + self.auctionLog[amount]! // get total in logs
            }
            return total == self.auctionVault.balance    // compare total to Vault
        }

        // return royality information
        priv fun getRoyality(): {Address : UFix64} {
            let royality = self.auctionNFT?.royality! // get Royality data
            return royality                           // return Royalty
        }
        
        // Resets all variables that need to be reset for restarting a reprintSeries auction.
        priv fun resetAuction() {
            //pre { self.auctionVault.balance == 0.0 : "Internal Error: Serial Minter" }  // already called by SerialMinter          
            if !self.reprintSeries { return } // if reprint is set to off (false) return

            self.leader = nil
            self.start = getCurrentBlock().timestamp // reset new auction to start at current time
            self.length = self.origLength
            self.auctionLog = {}
            self.minBid = self.startingBid
            self.status = true
            self.height = nil 
            log("Reset: Variables")
        }

        // Where the reprintSeries Mints another NFT.
        priv fun seriesMinter() {
            pre { self.auctionVault.balance == 0.0 : "Internal Error: Serial Minter" } // Verifty funds from previous auction are gone.
            if !self.reprintSeries { return } // if reprint is set to false, return

            let metadataGen = AuctionHouse.metadataGen[self.mid]!.borrow()!   // get Metadata Generator Reference
            let metadataRef = metadataGen.getMetadataRef(mid: self.mid)       // get Metadata Referencee
            let creator = metadataRef.creator                                 // get Creator from Metadata
            if creator != self.owner?.address! { return }                     // Verify Owner is Creator
            let metadata <- metadataGen.generateMetadata(mid: self.mid)       // get Metadata from Metadata Generator
            let old <- self.auctionNFT <- AuctionHouse.mintNFT(metadata: <-metadata) // Mint NFT and deposit into auction
            destroy old // destroy place holder

            self.resetAuction() // reset variables for next auction
        } 

        // End reprints. Set to OFF
        access(contract) fun endReprints() {
           pre {
                self.reprintSeries : "Reprints is already off."
                self.auctionNFT?.metadata!.creator == self.owner?.address! : "You are not the Creator of this NFT"
                //self.auctionNFT.metadata.series != 1 : "This is a 1-Shot NFT" // not reachable
           }
           self.reprintSeries = false
        } 

        destroy() { // Verify no Funds, NFT are in storage
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
        minter.notNew(tokenID: tokenID) // Set to not new
    }


    // Requires Minter Key // Minter function to mint
    access(contract) fun mintNFT(metadata: @DAAM.MetadataHolder): @DAAM.NFT {
        let minter = self.account.borrow<&DAAM.Minter>(from: DAAM.minterStoragePath)! // get Minter Reference
        let nft <- minter.mintNFT(metadata: <-metadata)! // Mint NFT
        return <- nft                                    // Return NFT
    }

    // Create Auction Wallet which is used for storing Auctions.
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
