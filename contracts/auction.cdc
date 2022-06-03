// auction.cdc
// by Ami Rajpal, 2021 // DAAM_V11 Agency

import FungibleToken    from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x1784abd15a9f29a8
import DAAM_V11         from 0xa4ad5ea5c0bd2fba

pub contract AuctionHouse {
    // Events
    pub event AuctionCreated(auctionID: UInt64, start: UFix64)   // Auction has been created. 
    pub event AuctionClosed(auctionID: UInt64)    // Auction has been finalized and has been removed.
    pub event AuctionCancelled(auctionID: UInt64) // Auction has been canceled
    pub event ItemReturned(auctionID: UInt64)     // Auction has ended and the Reserve price was not met.
    pub event BidMade(auctionID: UInt64, bidder: Address ) // Bid has been made on an Item
    pub event BidWithdrawn(auctionID: UInt64, bidder: Address)                // Bidder has withdrawn their bid
    pub event ItemWon(auctionID: UInt64, winner: Address)  // Item has been Won in an auction
    pub event BuyItNow(auctionID: UInt64, winner: Address, amount: UFix64) // Buy It Now has been completed
    pub event FundsReturned(auctionID: UInt64)   // Funds have been returned accordingly

    // Path for Auction Wallet
    pub let auctionStoragePath: StoragePath
    pub let auctionPublicPath : PublicPath

    // Variables; *Note: Do not confuse (Token)ID with MID
                                       // { MID   : Capability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorMint}> }
    access(contract) var metadataGen    : {UInt64 : Capability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorMint}> }
    access(contract) var auctionCounter : UInt64               // Incremental counter used for AID (Auction ID)
    access(contract) var currentAuctions: {Address : [UInt64]} // {Auctioneer Address : [list of Auction IDs (AIDs)] }  // List of all auctions
    access(contract) var fee            : {UInt64 : UFix64}    // { MID : Fee precentage, 1.025 = 0.25% }
/**********************`**************************************************/
pub struct AuctionInfo {
        pub let status        : Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        pub let auctionID     : UInt64       // Auction ID number. Note: Series auctions keep the same number. 
        pub let creators      : [Address]
        pub let mid           : UInt64       // collect Metadata ID
        pub let start         : UFix64       // timestamp
        pub let length        : UFix64   // post{!isExtended && length == before(length)}
        pub let isExtended    : Bool     // true = Auction extends with every bid.
        pub let extendedTime  : UFix64   // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
        pub let leader        : Address? // leading bidder
        pub let minBid        : UFix64?  // minimum bid
        pub let startingBid   : UFix64?  // the starting bid od an auction. Nil = No Bidding. Direct Purchase
        pub let reserve       : UFix64   // the reserve. must be sold at min price.
        pub let fee           : UFix64   // the fee
        pub let price         : UFix64   // original price
        pub let buyNow        : UFix64   // buy now price (original price + AuctionHouse.fee)
        pub let reprintSeries : Bool     // Active Series Minter (if series)
        pub let auctionLog    : {Address: UFix64}    // {Bidders, Amount} // Log of the Auction
        pub let requiredCurrency: Type

        init(
            _ status:Bool?, _ auctionID:UInt64, _ creators: [Address], _ mid: UInt64, _ start: UFix64, _ length: UFix64,
            _ isExtended: Bool, _ extendedTime: UFix64, _ leader: Address?, _ minBid: UFix64?, _ startingBid: UFix64?,
            _ reserve: UFix64, _ fee: UFix64, _ price: UFix64, _ buyNow: UFix64, _ reprintSeries: Bool,
            _ auctionLog: {Address: UFix64}, _ requiredCurrency: Type
            )
            {
                self.status        = status// nil = auction not started or no bid, true = started (with bid), false = auction ended
                self.auctionID     = auctionID       // Auction ID number. Note: Series auctions keep the same number. 
                self.creators      = creators
                self.mid           = mid       // collect Metadata ID
                self.start         = start       // timestamp
                self.length        = length   // post{!isExtended && length == before(length)}
                self.isExtended    = isExtended     // true = Auction extends with every bid.
                self.extendedTime  = extendedTime   // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
                self.leader        = leader // leading bidder
                self.minBid        = minBid  // minimum bid
                self.startingBid   = startingBid // the starting bid od an auction. Nil = No Bidding. Direct Purchase
                self.reserve       = reserve   // the reserve. must be sold at min price.
                self.fee           = fee   // the fee
                self.price         = price   // original price
                self.buyNow        = buyNow   // buy now price (original price + AuctionHouse.fee)
                self.reprintSeries = reprintSeries     // Active Series Minter (if series)
                self.auctionLog    = auctionLog    // {Bidders, Amount} // Log of the Auction
                self.requiredCurrency = requiredCurrency
            }
}
/**********************`**************************************************/
    pub resource interface AuctionWalletPublic {
        // Public Interface for AuctionWallet
        pub fun getAuctions(): [UInt64] // MIDs in Auctions
        pub fun item(_ id: UInt64): &Auction{AuctionPublic}? // item(Token ID) will return the apporiate auction.
        pub fun closeAuctions()
    }
/************************************************************************/
    pub resource AuctionWallet: AuctionWalletPublic {
        priv var currentAuctions: @{UInt64 : Auction}  // { TokenID : Auction }

        init() { self.currentAuctions <- {} }  // Auction Resources are stored here. The Auctions themselves.

        // createOriginalAuction: An Original Auction is defined as a newly minted NFT.
        // MetadataGenerator: Reference to Metadata
        // mid: DAAM_V11 Metadata ID
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
        pub fun createOriginalAuction(metadataGenerator: Capability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorMint}>, mid: UInt64, start: UFix64,
            length: UFix64, isExtended: Bool, extendedTime: UFix64, vault: @FungibleToken.Vault, incrementByPrice: Bool, incrementAmount: UFix64,
            startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool): UInt64
        {
            pre {
                metadataGenerator.borrow() != nil        : "There is no Metadata."
                DAAM_V11.getCopyright(mid: mid) != DAAM_V11.CopyrightStatus.FRAUD : "This submission has been flaged for Copyright Issues."
                DAAM_V11.getCopyright(mid: mid) != DAAM_V11.CopyrightStatus.CLAIM : "This submission has been flaged for a Copyright Claim." 
                self.validToken(vault: &vault as &FungibleToken.Vault)       : "We do not except this Token."
            }

            AuctionHouse.metadataGen.insert(key: mid, metadataGenerator) // add access to Creators' Metadata
            let metadataRef = metadataGenerator.borrow()! as &DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorMint} // Get MetadataHolder
            let minterAccess <- AuctionHouse.minterAccess()
            let metadata <-! metadataRef.generateMetadata(minter: <- minterAccess, mid: mid)      // Create MetadataHolder

            let nft <- AuctionHouse.mintNFT(metadata: <-metadata)        // Create NFT

            // Create Auctions
            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime, vault: <-vault,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)
            // Add Auction
            let aid = auction.auctionID // Auction ID
            let oldAuction <- self.currentAuctions.insert(key: aid, <- auction) // Store Auction
            destroy oldAuction // destroy placeholder

            AuctionHouse.currentAuctions.insert(key:self.owner?.address!, self.currentAuctions.keys) // Update Current Auctions
            return aid
        }

        // Creates an auction for a NFT as opposed to Metadata. An existing NFT.
        // same arguments as createOriginalAuction except for reprintSeries
        pub fun createAuction(nft: @DAAM_V11.NFT, start: UFix64, length: UFix64, isExtended: Bool,
            extendedTime: UFix64, vault: @FungibleToken.Vault, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64): UInt64
        {
            pre {
                DAAM_V11.getCopyright(mid: nft.mid) != DAAM_V11.CopyrightStatus.FRAUD : "This submission has been flaged for Copyright Issues."
                DAAM_V11.getCopyright(mid: nft.mid) != DAAM_V11.CopyrightStatus.CLAIM : "This submission has been flaged for a Copyright Claim." 
                self.validToken(vault: &vault as &FungibleToken.Vault)       : "We do not except this Token."
            }

            let auction <- create Auction(nft: <-nft, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime, vault: <-vault,
              incrementByPrice: incrementByPrice, incrementAmount: incrementAmount, startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: false)
            // Add Auction
            let aid = auction.auctionID // Auction ID
            let oldAuction <- self.currentAuctions.insert(key: aid, <- auction) // Store Auction
            destroy oldAuction // destroy placeholder
            
            AuctionHouse.currentAuctions.insert(key: self.owner?.address!, self.currentAuctions.keys) // Update Current Auctions
            return aid
        }

        // Resolves all Auctions. Closes ones that have been ended or restarts them due to being a reprintSeries auctions.
        // This allows the auctioneer to close auctions to auctions that have ended, returning funds and appropriating items accordingly
        // even in instances where the Winner has not claimed their item.
        pub fun closeAuctions()
        {
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
                    
                    // Update Current Auctions List
                    if AuctionHouse.currentAuctions[self.owner!.address]!.length == 0 {
                        AuctionHouse.currentAuctions.remove(key:self.owner!.address) // If auctioneer has no more auctions remove from list
                    } else {
                        AuctionHouse.currentAuctions.insert(key:self.owner!.address, self.currentAuctions.keys) // otherwise update list
                    }

                    log("Auction Closed: ".concat(auctionID.toString()) )
                    emit AuctionClosed(auctionID: auctionID)
                }
            }
        }

        // item(Auction ID) return a reference of the auctionID Auction
        pub fun item(_ aid: UInt64): &Auction{AuctionPublic}? { 
            pre { self.currentAuctions.containsKey(aid) }
            return &self.currentAuctions[aid] as &Auction{AuctionPublic}?
        }

        pub fun setting(_ aid: UInt64): &Auction? { 
            pre { self.currentAuctions.containsKey(aid) }
            return &self.currentAuctions[aid] as &Auction?
        }
        
        pub fun getAuctions(): [UInt64] { return self.currentAuctions.keys } // Return all auctions by User

        pub fun endReprints(auctionID: UInt64) { // Toggles the reprint to OFF. Note: This is not a toggle
            pre {
                self.currentAuctions.containsKey(auctionID)     : "AuctionID does not exist"
                self.currentAuctions[auctionID]?.reprintSeries! : "Reprint is already set to Off."
            }
            self.currentAuctions[auctionID]?.endReprints()
        }

        priv fun validToken(vault: &FungibleToken.Vault): Bool {
            let type = vault.getType()
            let identifier = type.identifier
            switch identifier {
                case "A.e223d8a629e49c68.FUSD.Vault": return true
            }
            return false
        }

        destroy() { destroy self.currentAuctions }
    }
/************************************************************************/
    pub resource interface AuctionPublic {
        pub fun depositToBid(bidder: Address, amount: @FungibleToken.Vault) // @AnyResource{FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance}
        pub fun withdrawBid(bidder: AuthAccount): @FungibleToken.Vault
        pub fun auctionInfo(): AuctionInfo?
        pub fun winnerCollect()
        pub fun getBuyNowAmount(bidder: Address): UFix64
        pub fun getMinBidAmount(bidder: Address): UFix64?
        pub fun buyItNow(bidder: Address, amount: @FungibleToken.Vault)
        pub fun buyItNowStatus(): Bool
        pub fun getAuctionLog(): {Address:UFix64}
        pub fun getStatus(): Bool?
        pub fun itemInfo(): DAAM_V11.MetadataHolder?
        pub fun timeLeft(): UFix64?
    }
/************************************************************************/
    pub resource Auction: AuctionPublic {
        access(contract) var status: Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        priv var height     : UInt64?      // Stores the final block height made by the final bid only.
        pub var auctionID   : UInt64       // Auction ID number. Note: Series auctions keep the same number. 
        pub let creators    : [Address]
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
        pub let fee           : UFix64   // the fee
        pub let price         : UFix64   // original price
        pub let buyNow        : UFix64   // buy now price original price
        pub var reprintSeries : Bool     // Active Series Minter (if series)
        pub var auctionLog    : {Address: UFix64}    // {Bidders, Amount} // Log of the Auction
        access(contract) var auctionNFT : @DAAM_V11.NFT? // Store NFT for auction
        priv var auctionVault : @FungibleToken.Vault // Vault, All funds are stored.
        pub let requiredCurrency: Type
    
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
        init(nft: @DAAM_V11.NFT, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, vault: @FungibleToken.Vault,
          incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool) {
            pre {
                start >= getCurrentBlock().timestamp : "Time has already past."
                length >= 60.0                       : "Minimum is 1 min"
                buyNow > reserve || buyNow == 0.0    : "The BuyNow option must be greater then the Reserve."
                startingBid != 0.0 : "You can not have a Starting Bid of zero."
                isExtended && extendedTime >= 20.0 || !isExtended && extendedTime == 0.0 : "Extended Time setting are incorrect. The minimim is 20 seconds."
                reprintSeries && nft.metadata.edition.max != 1 || !reprintSeries : "This can not be reprinted."
                startingBid == nil && buyNow != 0.0 || startingBid != nil : "Direct Purchase requires BuyItNow amount"
            }

            if startingBid != nil { // Verify starting bid is lower then the reserve price
                if reserve < startingBid! { panic("The Reserve must be greater then your Starting Bid") }
            }
                     
            // Manage incrementByPrice
            if incrementByPrice == false && incrementAmount < 0.01  { panic("The minimum increment is 1.0%.")   }
            if incrementByPrice == false && incrementAmount > 0.05  { panic("The maximum increment is 5.0%.")     }
            if incrementByPrice == true  && incrementAmount < 1.0   { panic("The minimum increment is 1 Crypto.") }

            AuctionHouse.auctionCounter = AuctionHouse.auctionCounter + 1 // increment Auction Counter
            self.status = nil // nil = auction not started, true = auction ongoing, false = auction ended
            self.height = nil  // when auction is ended does it get a value
            self.auctionID = AuctionHouse.auctionCounter // Auction uinque ID number
            var creators: [Address] = []
            for c in nft.metadata.creatorInfo.creator.keys { creators.append(c) }
            self.creators = creators
            self.mid = nft.mid // Metadata ID
            self.start = start        // When auction start
            self.length = length      // Length of auction
            self.origLength = length  // If length is reset (extneded auction), a new reprint can reset the original length
            self.leader = nil         // Current leader, when nil = no leader
            self.minBid = startingBid // when nil= Direct Purchase, buyNow Must have a value
            self.isExtended = isExtended // isExtended status
            self.extendedTime = (isExtended) ? extendedTime : 0.0 // Store extended time
            self.increment = {incrementByPrice : incrementAmount} // Store increment 
            
            self.startingBid = startingBid 
            self.reserve = reserve
            self.fee = AuctionHouse.getFee(mid: self.mid)
            self.price = buyNow
            self.buyNow = self.price * (self.fee + 1.0)
            // if last in series don't reprint.
            self.reprintSeries = nft.metadata.edition.max == nft.metadata.edition.number ? false : reprintSeries

            self.auctionLog = {} // Maintain record of Crypto // {Address : Crypto}
            self.auctionVault <- vault  // ALL Crypto is stored
            self.requiredCurrency = self.auctionVault.getType()
            self.auctionNFT <- nft // NFT Storage durning auction

            log("Auction Initialized: ".concat(self.auctionID.toString()) )
            emit AuctionCreated(auctionID: self.auctionID, start: self.start)
        }

        // Makes Bid, Bids are deposited into vault
        pub fun depositToBid(bidder: Address, amount: @FungibleToken.Vault) {
            pre {
                amount.isInstance(self.requiredCurrency) : "Incorrect payment currency"    
                self.minBid != nil                    : "No Bidding. Direct Purchase Only."     
                self.updateStatus() == true           : "Auction is not in progress."
                self.validateBid(bidder: bidder, balance: amount.balance) : "You have made an invalid Bid."
                self.leader != bidder                 : "You are already lead bidder."
                self.owner!.address != bidder         : "You can not bid in your own auction."
                self.height == nil || getCurrentBlock().height < self.height! : "You bid was too late"
            }
            post { self.verifyAuctionLog() } // Verify Funds

            log("self.minBid: ".concat(self.minBid!.toString()) )

            self.leader = bidder                        // Set new leader
            self.updateAuctionLog(amount.balance)       // Update logs with new balance
            self.incrementminBid()                      // Increment accordingly
            self.auctionVault.deposit(from: <- amount)  // Deposit Crypto into Vault
            self.extendAuction()                        // Extendend auction if applicable

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
            let amount <- self.auctionVault.withdraw(amount: balance) // Withdraw balance from Vault
            log("Bid Withdrawn")
            emit BidWithdrawn(auctionID: self.auctionID, bidder: bidder.address)    
            return <- amount  // return bidders deposit amount
        }

        pub fun auctionInfo(): AuctionInfo {
            let info = AuctionInfo(
                self.status, self.auctionID, self.creators, self.mid, self.start, self.length, self.isExtended,
                self.extendedTime, self.leader, self.minBid, self.startingBid, self.reserve, self.fee,
                self.price, self.buyNow, self.reprintSeries, self.auctionLog, self.requiredCurrency
            )
            return info
        }

        // Winner can 'Claim' an item. Reserve price must be meet, otherwise returned to auctioneer
        pub fun winnerCollect() {
            pre{ self.updateStatus() == false  : "Auction has not Ended." }
            self.verifyReservePrice() // Verify Reserve price is met
        }

        // This is a key function where are all the action happens.
        // Verifies the Reserve Price is met. 
        // Calls royalty() & ReturnFunds() and manages all royalities and funds are returned
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

            if pass { // leader met the reserve price
                // remove leader from log before returnFunds()!!
                self.auctionLog.remove(key: self.leader!)!
                self.returnFunds()  // return funds to all bidders
                self.royalty()     // pay royalty
                log("Item: Won")
                emit ItemWon(auctionID: self.auctionID, winner: self.leader!) // Auction Ended, but Item not delivered yet.
            } else {                
                receiver = self.owner!.address // set receiver from leader to auctioneer
                self.returnFunds()              // return funds to all bidders
                log("Item: Returned")
                emit ItemReturned(auctionID: self.auctionID)    
            }
            log("receiver: ".concat(receiver!.toString()) )   
            let collectionRef = getAccount(receiver!).getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM_V11.collectionPublicPath).borrow()!
            // NFT Deposot Must be LAST !!! *except for seriesMinter
            let nft <- self.auctionNFT <- nil     // remove nft

            var isLast = false
            if nft?.metadata!.edition.max != nil { 
                isLast = (nft?.metadata!.edition.number <= nft?.metadata!.edition.max!)
            }
            
            log("vrp(); Print Number: ")
            log(nft?.metadata!.edition.number)
            log("vrp(); Max: ")
            log(nft?.metadata!.edition.max)

            collectionRef.deposit(token: <- nft!) // deposit nft

            if pass && !isLast { // possible re-auction Series Minter                
                self.seriesMinter() // Note must be last after transer of NFT
            }
        }

        // Verifies amount is equal to the buyNow amount. If not returns false
        priv fun verifyBuyNowAmount(bidder: Address, amount: UFix64): Bool {
            log("self.buyNow: ".concat(self.buyNow.toString()) )
            
            var total = amount
            log("total: ".concat(total.toString()) )
            if self.auctionLog[bidder] != nil { 
                total = total + self.auctionLog[bidder]! // get bidders' total deposit
            }
            log("total: ".concat(total.toString()) )
            return self.buyNow == total // compare bidders' total deposit to buyNow
        }

        // Return the amount needed to make the correct bid
        pub fun getBuyNowAmount(bidder: Address): UFix64 {
            // If no bid had been made return buynow price, else return the difference
            return (self.auctionLog[bidder]==nil) ? self.buyNow : (self.buyNow-self.auctionLog[bidder]!)
        }
        
        // Return the amount needed to make the correct bid
        pub fun getMinBidAmount(bidder: Address): UFix64? {
            // If no bid had been made return minimum bid, else return the difference
            if self.minBid == nil { return nil } // Buy Now Only, return nil
            return (self.auctionLog[bidder]==nil) ? self.minBid : (self.minBid! - self.auctionLog[bidder]!)
        }

        // Record total amount of Crypto a bidder has deposited. Manages Log of that total.
        priv fun updateAuctionLog(_ amount: UFix64) {
            if !self.auctionLog.containsKey(self.leader!) {        // First bid by user
                self.auctionLog.insert(key: self.leader!, amount)  // append log for new bidder and log amount
            } else {
                let total = self.auctionLog[self.leader!]! + amount // get new total deposit of bidder
                self.auctionLog[self.leader!] = total               // append log with new amount
            }
        }          

        // To purchase the item directly. 
        pub fun buyItNow(bidder: Address, amount: @FungibleToken.Vault) {
            pre {
                amount.isInstance(self.requiredCurrency) : "Incorrect Crypto." 
                self.updateStatus() != false  : "Auction has Ended."
                self.buyNow != 0.0 : "Buy It Now option is not available."
                self.verifyBuyNowAmount(bidder: bidder, amount: amount.balance) : "Wrong Amount."
                // Must be after the above line.
                self.buyItNowStatus() : "Buy It Now option has expired."
            }
            post { self.verifyAuctionLog() } // verify log

            self.status = false          // ends the auction
            self.length = 0.0            // set length to 0; double end auction
            self.leader = bidder // set new leader

            self.updateAuctionLog(amount.balance)       // update auction log with new leader
            self.auctionVault.deposit(from: <- amount)  // depsoit into Auction Vault

            log("Buy It Now")
            emit BuyItNow(auctionID: self.auctionID, winner: self.leader!, amount: self.buyNow)                         // pay royalities

            log(self.auctionLog)
            self.winnerCollect() // Will receive NFT if reserve price is met
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
        // Note: leader is typically removed from auctionLog before called.
        priv fun returnFunds() {
            post { self.auctionLog.length == 0 : "Illegal Operation: returnFunds" } // Verify auction log is empty
            for bidder in self.auctionLog.keys {
                // get Crypto Wallet capability
                let bidderRef =  getAccount(bidder).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver).borrow()!
                let amount <- self.auctionVault.withdraw(amount: self.auctionLog[bidder]!)  // Withdraw amount
                self.auctionLog.remove(key: bidder)
                bidderRef.deposit(from: <- amount)  // Deposit amount to bidder
            }
            log("Funds Returned")
            emit FundsReturned(auctionID: self.auctionID)
        }

        pub fun getAuctionLog(): {Address:UFix64} {
            return self.auctionLog
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

        pub fun itemInfo(): DAAM_V11.MetadataHolder? { // returns the metadata of the item NFT.
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

        priv fun pay() {
            let price = self.auctionVault.balance   // get price of NFT
            let royalties = self.auctionNFT?.royalty!.getRoyalties() // get Royalty data
            for royalty in royalties {
                let cut <-! self.auctionVault.withdraw(amount: price * royalty.cut)  // Calculate Agency Crypto share
                let cap = royalty.receiver.borrow()!
                cap.deposit(from: <-cut ) //deposit royalty share
            }
        }

        // Returns a percentage of Group. Ex: Bob owns 10%, with percentage at 0.2, will return Bob at 8% along with the rest of Group
        priv fun payFirstSale() {
            let royalties = self.auctionNFT?.royalty!.getRoyalties() // get Royalty data
            let price = self.auctionVault.balance 
            for royalty in royalties {
                let amount = price * royalty.cut // ((royalty.description=="Agency") ? 0.2 : 0.8)
                let cut <-! self.auctionVault.withdraw(amount: amount)  // Calculate Agency Crypto share
                let cap = royalty.receiver.borrow()!
                cap.deposit(from: <-cut ) //deposit royalty share
            }
        }

        // Royalty rates are gathered from the NFTs metadata and funds are proportioned accordingly.
        priv fun royalty()
        {
            post { self.auctionVault.balance == 0.0 : "Royalty Error: ".concat(self.auctionVault.balance.toString() ) } // The Vault should always end empty
            if self.auctionVault.balance == 0.0 { return } // No need to run, already processed.
            let tokenID = self.auctionNFT?.id!      // get TokenID
            
            // If 1st sale is 'new' remove from 'new list'
            if DAAM_V11.isNFTNew(id: tokenID) {
                //self.payFirstSale()
                AuctionHouse.notNew(tokenID: tokenID) 
            } else {
                //self.pay(amount: price)
            }
            let seller = self.owner?.getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)!.borrow()! // get Seller FUSD Wallet Capability
            let sellerCut <-! self.auctionVault.withdraw(amount: self.auctionVault.balance) // Calcuate actual amount
            seller.deposit(from: <-sellerCut ) // deposit amount
        }

        // Comapres Log to Vault. Makes sure Funds match. Should always be true!
        priv fun verifyAuctionLog(): Bool {
            var total = 0.0
            for bidder in self.auctionLog.keys {
                total = total + self.auctionLog[bidder]! // get total in logs
            }
            log("Verify Auction Log: ")
            log(self.auctionLog)
            log("AID: ".concat(self.auctionID.toString()) )
            return total == self.auctionVault.balance    // compare total to Vault
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
            if !self.reprintSeries { return } // if reprint is set to false, skip function
            if self.creators[0] != self.owner!.address { return } // Verify Owner is Creator (element 0) otherwise skip function

            let metadataRef = AuctionHouse.metadataGen[self.mid]!.borrow()!   // get Metadata Generator Reference
            let minterAccess <- AuctionHouse.minterAccess()
            let metadata <-! metadataRef.generateMetadata(minter: <- minterAccess, mid: self.mid)
            let old <- self.auctionNFT <- AuctionHouse.mintNFT(metadata: <-metadata) // Mint NFT and deposit into auction
            destroy old // destroy place holder

            self.resetAuction() // reset variables for next auction
        } 

        // End reprints. Set to OFF
        access(contract) fun endReprints() {
           pre {
                self.reprintSeries : "Reprints is already off."
                self.auctionNFT?.metadata!.creatorInfo.creator.keys[0] == self.owner!.address : "You are not the Creator of this NFT"
                //self.auctionNFT.metadata.series != 1 : "This is a 1-Shot NFT" // not reachable
           }
           self.reprintSeries = false
        }

        // Auctions can be cancelled if they have no bids.
        pub fun cancelAuction() {
            pre {
                self.updateStatus() == nil || true         : "Too late to cancel Auction."
                self.auctionLog.length == 0                : "You already have a bid. Too late to Cancel."
            }
            
            self.status = false
            self.length = 0.0 as UFix64

            log("Auction Cancelled: ".concat(self.auctionID.toString()) )
            emit AuctionCancelled(auctionID: self.auctionID)
        } 

        destroy() { // Verify no Funds, NFT are NOT in storage, Auction has ended/closed.
            pre{
                self.auctionNFT == nil
                self.status == false
                self.auctionVault.balance == 0.0
            }
            // Re-Verify Funds Allocated Properly, since it's empty it should just pass
            self.returnFunds()
            self.royalty()

            destroy self.auctionVault
            destroy self.auctionNFT
        }
    }
/************************************************************************/
// AuctionHouse Functions & Constructor

    // Sets NFT to 'not new' 
    access(contract) fun notNew(tokenID: UInt64) {
        let minter = self.account.borrow<&DAAM_V11.Minter>(from: DAAM_V11.minterStoragePath)!
        minter.notNew(tokenID: tokenID) // Set to not new
    }

    // Get current auctions { Address : [AID] }
    pub fun getCurrentAuctions(): {Address:[UInt64]} {
        return self.currentAuctions
    }

    // Requires Minter Key // Minter function to mint
    access(contract) fun mintNFT(metadata: @DAAM_V11.Metadata): @DAAM_V11.NFT {
        let minterRef = self.account.borrow<&DAAM_V11.Minter>(from: DAAM_V11.minterStoragePath)! // get Minter Reference
        let nft <- minterRef.mintNFT(metadata: <-metadata)! // Mint NFT
        return <- nft                                    // Return NFT
    }

    // Requires Minter Key // Minter function to mint
    access(contract) fun minterAccess(): @DAAM_V11.MinterAccess {
        let minterRef = self.account.borrow<&DAAM_V11.Minter>(from: DAAM_V11.minterStoragePath)! // get Minter Reference
        let minter_access <- minterRef.createMinterAccess()
        return <- minter_access                                  // Return NFT
    }

    pub fun getFee(mid: UInt64): UFix64 {
        return (self.fee[mid] == nil) ? 0.025 : self.fee[mid]!
    }

    pub fun addFee(mid: UInt64, fee: UFix64, permission: &DAAM_V11.Admin) {
        pre { DAAM_V11.isAdmin(permission.owner!.address) == true : "Permission Denied" }
        self.fee[mid] = fee
    }

    pub fun removeFee(mid: UInt64, permission: &DAAM_V11.Admin) {
        pre {
            DAAM_V11.isAdmin(permission.owner!.address) == true : "Permission Denied" 
            self.fee.containsKey(mid) : "Mid does not exist."
        }
        self.fee.remove(key: mid)
    }

    // Create Auction Wallet which is used for storing Auctions.
    pub fun createAuctionWallet(): @AuctionWallet { 
        return <- create AuctionWallet() 
    }

    init() {
        self.metadataGen     = {}
        self.currentAuctions = {}
        self.fee             = {}
        self.auctionCounter  = 0
        self.auctionStoragePath = /storage/DAAM_V11_Auction
        self.auctionPublicPath  = /public/DAAM_V11_Auction
    }
}