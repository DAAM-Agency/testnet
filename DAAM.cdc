// DAAM, // Ami Rajpal
// Based on TopShots
// https://github.com/dapperlabs/nba-smart-contracts/blob/master/contracts/TopShot.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
//import DAAMCopyright from "DAAMCopyright.cdc"
import Profile from 0xf8d6e0586b0a20c7 //from "Profile.cdc"

// Events
    
    /*                // New NFT created
    //pub event NFTCreated(_ id: UInt64)

    pub event NewSeries(id: UInt32, title: String)     // New Series is created
    pub event NewCollection(id: UInt32, title: String) // New Collection is created
    pub event RemoveNFT(id: UInt32, title: String)     // Remove NFT
    pub event RemoveCollection(id: UInt32, title: String) // Remove Collection
    pub event RemoveSeries(id: UInt32, title: String)  // RemoveSeries
    //pub event AddNFTToCollection(nft: nft_REsource, collection: resource_collection) // Add NFT to Collection
    //pub event AddCollectionToSeries(collection: resource_collection, series: resurce_series)// Add Collection to Series
*/

pub contract DAAM_Agency: NonFungibleToken {
    // NonFungibleToken Events
    pub event ContractInitialized()  // Contract Initialization
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    
    // NonFungibleToken Declarations
    pub var totalSupply: UInt64 

    // Serial Numbers Generation
    //access(contract) var collectionIDCounter: UInt64
    //access(contract) var seriesIDCounter: UInt64    

    // NFT
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64                   // Unique ID
        access(contract) let file: String       // File
        access(contract) let thumbnail: String  // Thumbnail
        pub let bio: Metadata

        init(file: String, bio: Metadata, thumbnail: String) {
            self.file = file!
            DAAM_Agency.totalSupply = DAAM_Agency.totalSupply + 1 as UInt64
            self.id = DAAM_Agency.totalSupply
            self.thumbnail = thumbnail
            self.bio = bio
            
        }// NFT init        
    }

    // Metadata for NFT
    pub struct Metadata {
        pub let title: String                // Title
        pub let format: String               // File format
        pub let creator: &Profile.ReadOnly   // TODO FIX Artist
        pub let thumbnail_format: String     // Thumbnail format
        pub let about: String                // About NFT, Blurb or website
        pub let isPhysical: Bool             // Does this have a physical counter-part
        //pub let series: &Collection      // If, Part of which series  
        pub let agency: String               // Sold from which Gallery or Online // UPGRADE to NFT

        init(title:String, format:String, creator:&Profile.ReadOnly, thumbnail_format:String,
             about:String, physical:Bool, agency:String) {
            self.title = title!
            self.format = format!
            self.creator = creator!
            self.thumbnail_format = thumbnail_format
            self.about = about
            self.isPhysical = physical
            self.agency = agency
        }
    }

    // Collection is a resource that every user who owns NFTs will store in their account to manage their NFTS
    pub resource Collection: /*DAAMCollectionPublic,*/ NonFungibleToken.Provider, NonFungibleToken.Receiver,
    NonFungibleToken.CollectionPublic {          
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}  // Dictionary of conforming tokens
        init() { self.ownedNFTs <- {} }                     // NFT is a resource type with a UInt64 ID field

        // withdraw removes an NFT from the Collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {            
            let token <- self.ownedNFTs.remove(key: withdrawID) // Remove the nft from the Collection
                ?? panic("Cannot withdraw: Moment does not exist in the collection")
            
            emit Withdraw(id: token.id, from: self.owner?.address)            
            return <-token // Return the withdrawn token
        }
        
        // deposit takes an NFT into the Collections dictionary
        pub fun deposit(token: @NonFungibleToken.NFT) {       
            // Cast the deposited token as a DAAM_Agency NFT to make sure it is the correct type
            let token <- token as! @DAAM_Agency.NFT            
            let id = token.id  // Get the token's ID            
            let oldToken <- self.ownedNFTs[id] <- token  // Add the new token to the dictionary
            // Only emit a deposit event if the Collection is in an account's storage
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }
            destroy oldToken // Destroy the empty old token that was "removed"
        }

        // getIDs returns an array of the IDs that are in the Collection
        pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }

        // borrowNFT Returns a borrowed reference to an NFT in the Collection
        // so that the caller can read its ID
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun createEmptyCollection(): @NonFungibleToken.Collection {
            return <-create DAAM_Agency.Collection()
        }

        destroy() { destroy self.ownedNFTs }
    }// Collection

// self.about.mintID = DAAM_Agency.[Collection].minted
// DAAM_Agency.[NFT].minted = DAAM_Agency.[Collection].minted + 1
// self.about.totalMint = DAAM_Agency.[Collection].totalmint
/* 
              
          
        //access(contract) copyright: Copyright

        //access(contract) let totalMint: UInt32   // Total number of mints of this NFT     
        //access(contract) let mintID: UInt32      // Placing in totalMints, the first minited=1, the second=2, so forth
        
        
 
    pub struct Copyright {
        pub let included: Bool
        access(contract) var status: CapabilityPath

        init(_ included: Bool) {
            self.status = AuthAccount.link<&{Copyright}>(/public/Copyright/Unverified)!
            self.included = included
        } // Copyright init
    } // Copyright struct

        
    // pub fun createEmptyCollection(): @Collection { return <- create Collection("") } 
  */

    init() {
        //self.collectionIDCounter = 1
        //self.seriesIDCounter = 1
        self.totalSupply = 0        
        self.account.save<@Collection>(<- create Collection(), to: /storage/DAAM)  // Put a new Collection in storage        
        //self.account.link<&{DAAMCollectionPublic}>(/public/DAAM, target: /storage/DAAM)  // Create a public capability for the Collection
        self.account.save<@Admin>(<- create Admin(), to: /storage/DAAM_Admin) // Put the Minter in storage
        emit ContractInitialized()
    } // DAAM_Agency init

} // DAAM_Agency