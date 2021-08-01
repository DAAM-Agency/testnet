// auction.cdc
// by Ami Rajpal, 2021 // DAAM Agency

import FungibleToken    from 0xee82856bf20e2aa6
import FlowToken        from 0x0ae53cb6e3f42a79
import NonFungibleToken from 0x120e725050340cab

pub contract AuctionHouse {
    // Events
    pub event AuctionInitialized()
    pub event AuctionCreated(tokenID: UInt64)
    pub event AuctionCancelled(tokenID: UInt64)
    // Path
    pub let auctionStoragePath: StoragePath
    pub let auctionPublicPath : PublicPath
/************************************************************************/
    pub resource AuctionWallet {
        priv let titleholder  : Address
        pub var currentAuction: @{UInt64 : Auction}
        pub var auctionNFT: @{UInt64 : NonFungibleToken.NFT}
        pub var auctionRef    : {UInt64 : &Auction}

        init(owner: Address) {
            self.titleholder = owner
            self.currentAuction <- {}
            self.auctionNFT <- {}
            self.auctionRef = {}
        }

        pub fun createAuction(token: @NonFungibleToken.NFT, start: UFix64, length: UFix64, isExtended: Bool, increment: {Bool:UFix64},
        startingBid: UFix64, reserve: UFix64, buyNow: UFix64) {
            pre {
                self.titleholder == self.owner!.address   : "You are not the owner."
                !self.currentAuction.containsKey(token.id): "Already created an Auction for this TokenID."
            }
            post { self.currentAuction.containsKey(id) }

            let id = token.id
            let oldNFT <- self.auctionNFT[id] <- token
            destroy oldNFT

            let auction <- create Auction(tokenID: id, start: start, length: length, isExtended: isExtended, increment: increment,
              startingBid: startingBid, reserve: reserve, buyNow: buyNow)
            
             
            self.auctionRef[id] = &auction as &Auction

            let oldAuction <- self.currentAuction[id] <- auction
            destroy oldAuction
            
            log("Auction Created. Start: ".concat(start.toString()) )
            emit AuctionCreated(tokenID: id)
        }

        pub fun cancelAuction(tokenID: UInt64): @NonFungibleToken.NFT? {
            pre {
                self.titleholder == self.owner!.address  : "You are not the owner."
                self.currentAuction.containsKey(tokenID): "This Auction doesn not exist."
                self.auctionRef.containsKey(tokenID)
                self.auctionRef[tokenID]!.status == nil             : "Too late to cancel Auction."
            }
            post { !self.currentAuction.containsKey(tokenID) }

            let auction <- self.currentAuction.remove(key:tokenID)!
            destroy auction

            let nft <- self.auctionNFT.remove(key: tokenID)
            self.auctionRef.remove(key: tokenID)

            log("Auction Cancelled: ".concat(tokenID.toString()) )
            emit AuctionCancelled(tokenID: tokenID)
            return <- nft
        }

        pub fun winnerCollect(bidder: AuthAccount, tokenID: UInt64): @NonFungibleToken.NFT? {
            pre {
                self.auctionRef[tokenID]!.leader! == bidder.address ||
                self.titleholder == bidder.address : "You do not have access to the selected Auction"
            }
            self.auctionRef[tokenID!]!.updateStatus()
            let auction = self.auctionRef[tokenID]!
            if auction.auctionLog[auction.leader!]! >= auction.reserve {
                let nft <- self.auctionNFT.remove(key: tokenID)!
                return <- nft  
            }
            // return funds
            return nil           
        }   

        pub fun buyItNow(bidder: AuthAccount, amount: @FungibleToken.Vault) {
            pre {
                self.buyNow != 0.0
                self.buyNow == amount.balance
            }
            self.status = false  // ends the auction
            // nned to make it a DAAM NFT
            // make payment
            // return funds
            // send nft
        }

        destroy() {
            destroy self.currentAuction
            destroy self.auctionNFT
        }
    }
/************************************************************************/
    pub resource Auction {
        access(contract) var status: Bool? // nil = auction not started or no bid, true = started (with bid), false = auction ended
        pub let tokenID     : UInt64
        pub let start       : UFix64
        pub var length      : UFix64  // post{!isExtended && lenght == before(length)}
        pub let isExtended  : Bool
        pub var leader      : Address?
        pub var minBid      : UFix64
        pub let increment   : {Bool : UFix64} // true = is amount, false = is percentage *Note 1.0 = 100%
        pub let startingBid : UFix64
        pub let reserve     : UFix64
        pub let buyNow      : UFix64
        pub var auctionLog  : {Address: UFix64} // {Bidders, Amount}
        priv var auctionVault: @FungibleToken.Vault
    
        init(tokenID:UInt64, start: UFix64, length: UFix64, isExtended: Bool, increment: {Bool:UFix64},
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
            self.tokenID = tokenID
            self.start = start
            self.length = length
            self.leader = nil
            self.minBid = startingBid
            self.isExtended = isExtended
            self.increment = increment
            self.startingBid = startingBid
            self.reserve = reserve
            self.buyNow = buyNow
            self.auctionLog = {}
            self.auctionVault <- FlowToken.createEmptyVault()

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
            pre { self.status != false }
            let timeNow = getCurrentBlock().timestamp                            
            if self.start >= timeNow {
                self.status = (self.start + self.length) < timeNow ? true : false
            }
            return self.status
        }

        pub fun withdrawBid(bidder: AuthAccount, wallet: @FungibleToken.Vault): @FungibleToken.Vault {
            pre { self.auctionLog.containsKey(bidder.address) }
            let bidder_address = bidder.address
            let balance = self.auctionLog[bidder_address]!
            self.auctionLog.remove(key: bidder_address)
            let amount <- self.auctionVault.withdraw(amount: balance)!
            wallet.deposit(from: <- amount)
            self.updateStatus()
            return <- wallet
        }        

        destroy() { destroy self.auctionVault }
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