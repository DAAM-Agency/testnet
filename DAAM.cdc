//import NonFungibleToken from 0xf8d6e0586b0a20c7
//import DAAMCopyright from "DAAMCopyright.cdc"
import Profile "Profile.cdc"

// Events
    
    /*                // New NFT created
    pub event NewSeries(id: UInt32, title: String)     // New Series is created
    pub event NewCollection(id: UInt32, title: String) // New Collection is created
    pub event RemoveNFT(id: UInt32, title: String)     // Remove NFT
    pub event RemoveCollection(id: UInt32, title: String) // Remove Collection
    pub event RemoveSeries(id: UInt32, title: String)  // RemoveSeries
    //pub event AddNFTToCollection(nft: nft_REsource, collection: resource_collection) // Add NFT to Collection
    //pub event AddCollectionToSeries(collection: resource_collection, series: resurce_series)// Add Collection to Series
*/

pub contract DAAM_Agency {
    // Events
    pub event ContractInitialized()  // Contract Initialization
    pub event NFTCreated(_ id: UInt32)

    // Serial Numbers Generation
    access(contract) var nftIDCounter: UInt32
    access(contract) var collectionIDCounter: UInt32
    access(contract) var seriesIDCounter: UInt32    

    // DAAM NFT
    pub resource DAAMNFT {
        pub let nftID: UInt32           // Unique ID
        access(contract) let file: String
        access(contract) let thumbnail: String
        pub let bio: Metadata

        init(file: String, bio: Metadata, thumbnail: String) {
            self.file = file
            self.nftID = DAAM_Agency.nftIDCounter
            DAAM_Agency.nftIDCounter = DAAM_Agency.nftIDCounter + 1 as UInt32
            self.thumbnail = thumbnail
            self.bio = bio
            
        }// DAAM NFT init        
    }

    // Metadata for NFT
    pub struct Metadata {
        pub let title: String       // Title
        pub let format: String      // File format
        pub let creator: &Profile   // Artist

        init(title:String, format:String, creator: &Profile) {
            self.title = title
            self.format = format
            self.creator = creator
        }
    }

// self.about.mintID = DAAM_Agency.[Collection].minted
// DAAM_Agency.[NFT].minted = DAAM_Agency.[Collection].minted + 1
// self.about.totalMint = DAAM_Agency.[Collection].totalmint
         
    

    /*pub struct NFTData {
        pub let file: String
        //pub let thumbnail_format: String
        //pub let thumbnail: String
        //pub let bio: NFTData
        
        // Collection NFT belongs to, nill means belongs to no collection. Collection is on DAAM
        pub let series: &Collection
        pub let agency: String      // Sold from Gallery or Online // CHANGE TO NFT ??
        pub let isPhysical: Bool    // Does this have a physical counter-part        
        pub let about: String        // About NFT, Blurb or website
        //access(contract) copyright: Copyright

        //access(contract) let totalMint: UInt32   // Total number of mints of this NFT     
        //access(contract) let mintID: UInt32      // Placing in totalMints, the first minited=1, the second=2, so forth
        
        init(
            , series:&Collection, agenct:String,
            isPhysical:Bool, about:String, copyrightsIncluded: Bool) {           
                
                self.series = series!
                self.agency = agency
                self.isPhysical = isPhysical
                self.about = about
                // Copyright Variables         
                //self.copyright = Copyright(copyrightsIncluded)
                       
        } // NFTData init 
    } // NFTData struct
 
    pub struct Copyright {
        pub let included: Bool
        access(contract) var status: CapabilityPath

        init(_ included: Bool) {
            self.status = AuthAccount.link<&{Copyright}>(/public/Copyright/Unverified)!
            self.included = included
        } // Copyright init
    } // Copyright struct

    

    pub resource interface NFTReceiver {
        pub fun deposit(token: @ArtNFT)
        pub fun getIDs(): [UInt32]
        pub fun idExists(id: UInt32): Bool
    }  // NFTReceiver

    pub resource Collection: NFTReceiver {
        pub let collectionID: UInt32
        pub let name: String
        pub var ownedNFTs: @{UInt32: Art}

        init(name: String) {
            self.collectionID = DAAM_Agency.CollectionIDCounter
            self.DAAM_Agency.CollectionIDCounter = DAAM_Agency.CollectionIDCounter + 1
            self.name = name
            self.ownedNFTs <- {}
        } // Collection init

        pub fun withdraw(withdrawID: UInt32): @ArtNFT {
            let nft <- self.ownedNFTs.remove(key: withdrawID)!
            return <- nft
        } // Collection withdraw

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Art.NFT  // <= Don't forgrt to check NFT from NonFungileToken !!!
            self.ownedNFTs[token.id] <- token!
        } // Collection deposit

        pub fun getIDs(): [UInt32] { return self.ownedNFTs.keys }
        
        // pub fun createEmptyCollection(): @Collection { return <- create Collection("") } 
    } // Collection   */

    init() {
        self.nftIDCounter = 1
        self.collectionIDCounter = 1
        self.seriesIDCounter = 1
        emit ContractInitialized()
    } // DAAM_Agency init

} // DAAM_Agency