// Bases on Marketplace.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

pub contract Marketplace {

    // -----------------------------------------------------------------------
    // DAAM NFT Market contract Event definitions
    // -----------------------------------------------------------------------

    // emitted when a DAAM NFT moment is listed for sale
    pub event NFT_Listed(id: UInt64, price: UFix64, seller: Address?)
    // emitted when the price of a listed moment has changed
    pub event NFT_PriceChange(id: UInt64, newPrice: UFix64, seller: Address?)
    // emitted when a token is purchased from the market
    pub event NFT_Purchased(id: UInt64, price: UFix64, seller: Address?)
    // emitted when a moment has been withdrawn from the sale
    pub event NFT_Withdrawn(id: UInt64, owner: Address?)
    // emitted when the cut percentage of the sale has been changed by the owner
    pub event CutPercentageChanged(newPercent: UFix64, seller: Address?)

    pub let marketStoragePath: StoragePath
    pub let marketPublicPath : PublicPath
    pub let flowStoragePath: StoragePath
    pub let flowPublicPath :  PublicPath

    // SalePublic 
    //
    // The interface that a user can publish a capability to their sale
    // to allow others to access their sale
    pub resource interface SalePublic {
        pub var cutPercentage: UFix64
        pub fun purchase(tokenID: UInt64, buyTokens: @FungibleToken.Vault): @DAAM.NFT {
            post {
                result.id == tokenID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
        pub fun getPrice(tokenID: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
        pub fun borrowDAAM(id: UInt64): &DAAM.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Moment reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // SaleCollection
    pub resource SaleCollection: SalePublic {

        // A collection of the moments that the user has for sale
        access(self) var ownerCollection: Capability<&DAAM.Collection>

        // Dictionary of the low low prices for each NFT by ID
        access(self) var prices: {UInt64: UFix64}

        // The fungible token vault of the seller
        // so that when someone buys a token, the tokens are deposited
        // to this Vault
        access(self) var ownerCapability: Capability<&{FungibleToken.Receiver}>

        // The capability that is used for depositing 
        // the beneficiary's cut of every sale
        access(self) var beneficiaryCapability: Capability<&{FungibleToken.Receiver}>

        // The percentage that is taken from every purchase for the beneficiary
        // For example, if the percentage is 15%, cutPercentage = 0.15
        pub var cutPercentage: UFix64

        init (ownerCollection: Capability<&DAAM.Collection>, ownerCapability: Capability<&{FungibleToken.Receiver}>, beneficiaryCapability: Capability<&{FungibleToken.Receiver}>, cutPercentage: UFix64) {
            pre {
                // Check that the owner's moment collection capability is correct
                ownerCollection.borrow() != nil: 
                    "Owner's Moment Collection Capability is invalid!"

                // Check that both capabilities are for fungible token Vault receivers
                ownerCapability.borrow() != nil: 
                    "Owner's Receiver Capability is invalid!"
                beneficiaryCapability.borrow() != nil: 
                    "Beneficiary's Receiver Capability is invalid!"
                cutPercentage <= 0.3 : "That's too much!!"
                cutPercentage >= 0.1 : "That's too little!!"
            }
            
            // create an empty collection to store the moments that are for sale
            self.ownerCollection = ownerCollection
            self.ownerCapability = ownerCapability
            self.beneficiaryCapability = beneficiaryCapability
            // prices are initially empty because there are no moments for sale
            self.prices = {}
            self.cutPercentage = cutPercentage
        }

        // listForSale lists an NFT for sale in this sale collection
        // at the specified price
        //
        // Parameters: tokenID: The id of the NFT to be put up for sale
        //             price: The price of the NFT
        pub fun listForSale(tokenID: UInt64, price: UFix64) {
            pre {
                self.ownerCollection.borrow()!.borrowDAAM(id: tokenID) != nil:
                    "Moment does not exist in the owner's collection"
            }

            // Set the token's price
            self.prices[tokenID] = price

            emit NFT_Listed(id: tokenID, price: price, seller: self.owner?.address)
        }

        // cancelSale cancels a moment sale and clears its price
        //
        // Parameters: tokenID: the ID of the token to withdraw from the sale
        //
        pub fun cancelSale(tokenID: UInt64) {
            pre {
                self.prices[tokenID] != nil: "Token with the specified ID is not already for sale"
            }

            // Remove the price from the prices dictionary
            self.prices.remove(key: tokenID)

            // Set prices to nil for the withdrawn ID
            self.prices[tokenID] = nil
            
            // Emit the event for withdrawing a moment from the Sale
            emit NFT_Withdrawn(id: tokenID, owner: self.owner?.address)
        }

        // purchase lets a user send tokens to purchase an NFT that is for sale
        // the purchased NFT is returned to the transaction context that called it
        //
        // Parameters: tokenID: the ID of the NFT to purchase
        //             buyTokens: the fungible tokens that are used to buy the NFT
        //
        // Returns: @DAAM.NFT: the purchased NFT
        pub fun purchase(tokenID: UInt64, buyTokens: @FungibleToken.Vault): @DAAM.NFT {
            pre {
                self.ownerCollection.borrow()!.borrowDAAM(id: tokenID) != nil && self.prices[tokenID] != nil:
                    "No token matching this ID for sale!"           
                buyTokens.balance == (self.prices[tokenID] ?? UFix64(0)):
                    "Not enough tokens to buy the NFT!"
            }

            // Read the price for the token
            let price = self.prices[tokenID]!

            // Set the price for the token to nil
            self.prices[tokenID] = nil

            // Take the cut of the tokens that the beneficiary gets from the sent tokens
            let beneficiaryCut <- buyTokens.withdraw(amount: price*self.cutPercentage)

            // Deposit it into the beneficiary's Vault
            self.beneficiaryCapability.borrow()!
                .deposit(from: <-beneficiaryCut)
            
            // Deposit the remaining tokens into the owners vault
            self.ownerCapability.borrow()!
                .deposit(from: <-buyTokens)

            emit NFT_Purchased(id: tokenID, price: price, seller: self.owner?.address)

            // Return the purchased token
            let boughtMoment <- self.ownerCollection.borrow()!.withdraw(withdrawID: tokenID) as! @DAAM.NFT

            return <-boughtMoment
        }

        // changePercentage changes the cut percentage of the tokens that are for sale
        //
        // Parameters: newPercent: The new cut percentage for the sale
        pub fun changePercentage(_ newPercent: UFix64) {
            self.cutPercentage = newPercent

            emit CutPercentageChanged(newPercent: newPercent, seller: self.owner?.address)
        }

        // changeOwnerReceiver updates the capability for the sellers fungible token Vault
        //
        // Parameters: newOwnerCapability: The new fungible token capability for the account 
        //                                 who received tokens for purchases
        pub fun changeOwnerReceiver(_ newOwnerCapability: Capability<&{FungibleToken.Receiver}>) {
            pre {
                newOwnerCapability.borrow() != nil: 
                    "Owner's Receiver Capability is invalid!"
            }
            self.ownerCapability = newOwnerCapability
        }

        // changeBeneficiaryReceiver updates the capability for the beneficiary of the cut of the sale
        //
        // Parameters: newBeneficiaryCapability the new capability for the beneficiary of the cut of the sale
        //
        pub fun changeBeneficiaryReceiver(_ newBeneficiaryCapability: Capability<&{FungibleToken.Receiver}>) {
            pre {
                newBeneficiaryCapability.borrow() != nil: 
                    "Beneficiary's Receiver Capability is invalid!" 
            }
            self.beneficiaryCapability = newBeneficiaryCapability
        }

        // getPrice returns the price of a specific token in the sale
        // 
        // Parameters: tokenID: The ID of the NFT whose price to get
        //
        // Returns: UFix64: The price of the token
        pub fun getPrice(tokenID: UInt64): UFix64? {
            return self.prices[tokenID]
        }

        // getIDs returns an array of token IDs that are for sale
        pub fun getIDs(): [UInt64] {
            return self.prices.keys
        }

        // borrowDAAM Returns a borrowed reference to a Moment for sale
        // so that the caller can read data from it
        //
        // Parameters: id: The ID of the moment to borrow a reference to
        //
        // Returns: &DAAM.NFT? Optional reference to a moment for sale 
        //                        so that the caller can read its data
        //
        pub fun borrowDAAM(id: UInt64): &DAAM.NFT? {
            if self.prices[id] != nil {
                let ref = self.ownerCollection.borrow()!.borrowDAAM(id: id)
                return ref
            } else {
                return nil
            }
        }
    }

    // createCollection returns a new collection resource to the caller
    pub fun createSaleCollection(ownerCollection: Capability<&DAAM.Collection>, ownerCapability: Capability<&{FungibleToken.Receiver}>, beneficiaryCapability: Capability<&{FungibleToken.Receiver}>, cutPercentage: UFix64): @SaleCollection {
        return <- create SaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability, beneficiaryCapability: beneficiaryCapability, cutPercentage: cutPercentage)
    }

    init() {
        self.marketStoragePath = /storage/DAAM_SaleCollection
        self.marketPublicPath  = /public/DAAM_SaleCollection
        self.flowStoragePath = /storage/flowTokenVault
        self.flowPublicPath  = /public/flowTokenReceiver
    }
}