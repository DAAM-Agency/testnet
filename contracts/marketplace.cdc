import NonFungibleToken from 0x120e725050340cab
import FungibleToken from 0xee82856bf20e2aa6

// Marketplace.cdc
// Based on: https://docs.onflow.org/docs/composable-smart-contracts-marketplace

pub contract Marketplace
{    
    pub event ForSale(id: UInt64, price: UFix64)          // Event that is emitted when a new NFT is put up for sale    
    pub event PriceChanged(id: UInt64, newPrice: UFix64)  // Event that is emitted when the price of an NFT changes    
    pub event TokenPurchased(id: UInt64, price: UFix64)   // Event that is emitted when a token is purchased    
    pub event SaleWithdrawn(id: UInt64)                   // Event that is emitted when a seller withdraws their NFT from the sale

    pub let publicPath : PublicPath
    pub let storagePath: StoragePath

    // Interface that users will publish for their Sale collection that only exposes the methods that are supposed to be public
    pub resource interface SalePublic {
        pub fun purchase(tokenID: UInt64, recipient: &AnyResource{NonFungibleToken.Receiver}, buyTokens: @FungibleToken.Vault)
        pub fun idPrice(tokenID: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
    }
    
    // NFT Collection object that allows a user to put their NFT up for sale where others can send fungible tokens to purchase it
    pub resource SaleCollection: SalePublic
    {        
        pub var forSale: @{UInt64: NonFungibleToken.NFT}  // Dictionary of the NFTs that the user is putting up for sale        
        pub var prices: {UInt64: UFix64}                  // Dictionary of the prices for each NFT by ID

        // The fungible token vault of the owner of this sale. When someone buys a token, this resource can
        // deposit tokens into their account.
        access(account) let ownerVault: Capability<&AnyResource{FungibleToken.Receiver}>

        init (vault: Capability<&AnyResource{FungibleToken.Receiver}>) {
            self.forSale <- {}
            self.ownerVault = vault
            self.prices = {}
        }

        // withdraw gives the owner the opportunity to remove a sale from the collection
        pub fun withdraw(tokenID: UInt64): @NonFungibleToken.NFT {            
            self.prices.remove(key: tokenID)  // remove the price            
            let token <- self.forSale.remove(key: tokenID) ?? panic("missing NFT")  // remove and return the token
            return <-token
        }

        // listForSale lists an NFT for sale in this collection
        pub fun listForSale(token: @NonFungibleToken.NFT, price: UFix64) {
            let id = token.id           
            self.prices[id] = price  // store the price in the price array            
            let oldToken <- self.forSale[id] <- token  // put the NFT into the the forSale dictionary
            destroy oldToken

            emit ForSale(id: id, price: price)
        }

        // changePrice changes the price of a token that is currently for sale
        pub fun changePrice(tokenID: UInt64, newPrice: UFix64) {
            self.prices[tokenID] = newPrice
            emit PriceChanged(id: tokenID, newPrice: newPrice)
        }

        // purchase lets a user send tokens to purchase an NFT that is for sale
        pub fun purchase(tokenID: UInt64, recipient: &AnyResource{NonFungibleToken.Receiver}, buyTokens: @FungibleToken.Vault) {
            pre {
                self.forSale[tokenID] != nil && self.prices[tokenID] != nil:
                    "No token matching this ID for sale!"
                buyTokens.balance >= (self.prices[tokenID] ?? 0.0):
                    "Not enough tokens to by the NFT!"
            }

            
            let price = self.prices[tokenID]!  // get the value out of the optional            
            self.prices[tokenID] = nil

            let vaultRef = self.ownerVault.borrow()
                ?? panic("Could not borrow reference to owner token vault")           
            vaultRef.deposit(from: <-buyTokens)  // deposit the purchasing tokens into the owners vault

            // deposit the NFT into the buyers collection
            recipient.deposit(token: <-self.withdraw(tokenID: tokenID))
            emit TokenPurchased(id: tokenID, price: price)
        }

        // idPrice returns the price of a specific token in the sale
        pub fun idPrice(tokenID: UInt64): UFix64? {
            return self.prices[tokenID]
        }

        // getIDs returns an array of token IDs that are for sale
        pub fun getIDs(): [UInt64] {
            return self.forSale.keys
        }

        destroy() {
            destroy self.forSale
        }
    }

    // createCollection returns a new collection resource to the caller
    pub fun createSaleCollection(ownerVault: Capability<&AnyResource{FungibleToken.Receiver}>): @SaleCollection {
        return <- create SaleCollection(vault: ownerVault)
    }

    init(){
        self.publicPath  = /public/DAAMSale
        self.storagePath = /storage/DAAMSale
    }
}
 