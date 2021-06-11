// Bases on Marketplace.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d
/************************************************************************/
pub contract Marketplace {
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
    pub let flowStoragePath  : StoragePath
    pub let flowPublicPath   : PublicPath
/************************************************************************/
    pub resource interface SalePublic {
        pub fun purchase(tokenID: UInt64, recipient: &DAAM.Collection{NonFungibleToken.Receiver}, buyTokens: @FungibleToken.Vault)
        pub fun getPrice(tokenID: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
        pub fun borrowDAAM(id: UInt64): &DAAM.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow NFT reference: The ID of the returned reference is incorrect"
            }
        }// borrowDAAM
    }
/************************************************************************/
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

        init (ownerCollection: Capability<&DAAM.Collection>, ownerCapability: Capability<&{FungibleToken.Receiver}>) {
            pre {
                // Check that the owner's moment collection capability is correct
                ownerCollection.borrow() != nil: 
                    "Owner's Moment Collection Capability is invalid!"

                // Check that both capabilities are for fungible token Vault receivers
                ownerCapability.borrow() != nil: 
                    "Owner's Receiver Capability is invalid!"
            }
            
            // create an empty collection to store the moments that are for sale
            self.ownerCollection = ownerCollection
            self.ownerCapability = ownerCapability
            // prices are initially empty because there are no moments for sale
            self.prices = {}
        }

        // listForSale lists an NFT for sale in this sale collection
        // at the specified price
        //
        // Parameters: tokenID: The id of the NFT to be put up for sale
        //             price: The price of the NFT
        pub fun listForSale(tokenID: UInt64, price: UFix64) {
            pre {
                self.ownerCollection.borrow()!.borrowDAAM(id: tokenID) != nil:
                    "NFT does not exist in the owner's collection"
                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.FRAUD :
                "This NFT is flaged for Copyright Infrigement"
                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.CLAIM :
                "There is a Claim of Copyright Infrigement. This NFT is not temporary allowed"
                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.UNVERIFIED:
                "You're NFT Copyright is Unverified... WTF ?!?... Tell that DAAM Admin too Hurry the Fuck Up!!"
            }
            // Set the token's price
            self.prices[tokenID] = price
            emit NFT_Listed(id: tokenID, price: price, seller: self.owner?.address)
        }

        // cancelSale cancels a nft sale and clears its price
        pub fun cancelSale(tokenID: UInt64) {
            pre {
                self.prices[tokenID] != nil: "Token with the specified ID is not already for sale"
            }
            self.prices.remove(key: tokenID) // Remove the price from the prices dictionary            
            self.prices[tokenID] = nil       // Set prices to nil for the withdrawn ID
            // Emit the event for withdrawing a moment from the Sale
            emit NFT_Withdrawn(id: tokenID, owner: self.owner?.address)

            //TODO Consider removing Token and returning it to Collection
        }

        // purchase lets a user send tokens to purchase an NFT that is for sale
        // the purchased NFT is returned to the transaction context that called it
        pub fun purchase(tokenID: UInt64, recipient: &DAAM.Collection{NonFungibleToken.Receiver}, buyTokens: @FungibleToken.Vault) {
            pre {
                self.ownerCollection.borrow()!.borrowDAAM(id: tokenID) != nil : "No token matching this ID"
                self.prices[tokenID] != nil :"No token is not for sale!"           
                buyTokens.balance == (self.prices[tokenID]) : "Not enough tokens to buy the NFT!"

                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.FRAUD :
                "This NFT is flaged for Copyright Infrigement"
                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.CLAIM :
                "There is a Claim of Copyright Infrigement. This NFT is not temporary allowed"
            }

            post {
                // Durning Sale protection. If copyright is changed durning sale
                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.FRAUD :
                "This NFT is flaged for Copyright Infrigement"
                DAAM.copyright[tokenID] != DAAM.CopyrightStatus.CLAIM :
                "There is a Claim of Copyright Infrigement. This NFT is not temporary allowed"
            }

            // Take the cut of the tokens that the beneficiary gets from the sent tokens
            let boughtNFT <-! self.ownerCollection.borrow()!.withdraw(withdrawID: tokenID) as! @DAAM.NFT

            let price = self.prices[tokenID]!    // Read the price for the token
            self.prices[tokenID] = nil           // Set the price for the token to nil
            let agencyCommission      = boughtNFT.royality[DAAM.agency]!
            let creatorCommission = boughtNFT.royality[boughtNFT.metadata.creator]!

            let agencyCut      <-! buyTokens.withdraw(amount: price * agencyCommission)
            let creatorCut <-! buyTokens.withdraw(amount: price * creatorCommission)
            
            // Deposit it into the beneficiary's Vault
            let beneficiaryCapability = getAccount(boughtNFT.metadata.creator).getCapability<&AnyResource{FungibleToken.Receiver}>(Marketplace.flowPublicPath)
            beneficiaryCapability.borrow()!.deposit(from: <-creatorCut)
            // Deposit it into the agency's Vault
            let agencyCapability = getAccount(DAAM.agency).getCapability<&AnyResource{FungibleToken.Receiver}>(Marketplace.flowPublicPath)
            agencyCapability.borrow()!.deposit(from: <-agencyCut)
            
            self.ownerCapability.borrow()!       // Deposit the remaining tokens into the owners vault
                .deposit(from: <-buyTokens)

            let metadata = boughtNFT.metadata
            log("TokenID: ".concat(tokenID.toString()).concat(" MetadataID: ").concat(boughtNFT.metadata.mid.toString()) )
            recipient.deposit(token: <-boughtNFT)

            //self.updateSeries(metadata: metadata)
            emit NFT_Purchased(id: tokenID, price: price, seller: self.owner?.address)
        }

        // getPrice returns the price of a specific token in the sale
        pub fun getPrice(tokenID: UInt64): UFix64? {
            return self.prices[tokenID]
        }

        // getIDs returns an array of token IDs that are for sale
        pub fun getIDs(): [UInt64] {
            return self.prices.keys
        }

        // borrowDAAM Returns a borrowed reference to a Moment for sale
        pub fun borrowDAAM(id: UInt64): &DAAM.NFT? {
            if self.prices[id] != nil {
                let ref = self.ownerCollection.borrow()!.borrowDAAM(id: id)
                return ref
            } else {
                return nil
            }
        }

        priv fun updateSeries(metadata: DAAM.Metadata) {
            if metadata.series == 1 as UInt64          { return }
            if self.owner?.address != metadata.creator { return } // is the Seller aka Creator == NFT.metacreator; you're buying from the original collection/creator
            Marketplace.loadMinter(creator: metadata.creator, mid: metadata.mid, recipient: self.ownerCollection.borrow()! )
        }
    }
/************************************************************************/
    // createCollection returns a new collection resource to the caller
    pub fun createSaleCollection(ownerCollection: Capability<&DAAM.Collection>, ownerCapability: Capability<&{FungibleToken.Receiver}>): @SaleCollection {
        return <- create SaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability)
    }

    access(contract) fun loadMinter(creator: Address, mid: UInt64, recipient: &{NonFungibleToken.CollectionPublic} ) {
        let requestGen = self.account.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
        let minter = self.account.borrow<&DAAM.Creator{DAAM.SeriesMinter}>(from: DAAM.creatorStoragePath)!

        let metadataGenCap = getAccount(creator).getCapability<&DAAM.MetadataGenerator>(DAAM.metadataPublicPath)
        let metadataGen = metadataGenCap.borrow()!
        let mh <- metadataGen.generateMetadata(mid: mid)
        
        let request <- requestGen.getRequest(mid: mid)
        minter.mintNFT(recipient: recipient, metadata: <-mh, request: <-request)
    }

    init() {
        self.marketStoragePath = /storage/DAAM_SaleCollection
        self.marketPublicPath  = /public/DAAM_SaleCollection
        self.flowStoragePath = /storage/flowTokenVault
        self.flowPublicPath  = /public/flowTokenReceiver
    }
}