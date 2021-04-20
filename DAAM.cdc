Import NonFungibleToken from 0xNFTADDRESS

pub contract DAAM_Agency: NonFungibleToken {  
// Events
    pub event ContractInitialized()                    // Contract Initialization
    pub event NFTCreated(data: GetData)                // New NFT created
    pub event NewSeries(id: UInt32, title: String)     // New Series is created
    pub event NewCollection(id: UInt32, title: String) // New Collection is created
    pub event RemoveNFT(id: UInt32, title: String)     // Remove NFT
    pub event RemoveCollection(id: UInt32, title: String) // Remove Collection
    pub event RemoveSeries(id: UInt32, title: String)  // RemoveSeries
    //pub event AddNFTToCollection(nft: nft_REsource, collection: resource_collection) // Add NFT to Collection
    //pub event AddCollectionToSeries(collection: resource_collection, series: resurce_series)// Add Collection to Series

// Serial Numbers
    access(contract) var nftIDCounter: UInt32
    access(contract) var Collection_Id: UInt32
    access(contract) var Series_Id: UInt32

    pub struct NFTData {
        pub let nftID: UIInt32      // Unique ID
        pub let title: String       // Title
        pub let format: String      // File format
        pub let creator: &{Profile} // Artist
        // Collection NFT belongs to, nill means belongs to no collection. Collection is on DAAM
        pub let collection: &{Collection} 
        pub let agency: String      // Sold from Gallery or Online // CHANGE TO NFT ??
        pub let isPhysical: bool    // Does this have a physical counter-part        
        pub let bio: String         // About NFT, Blurb or website

        pub let totalMint: UInt32   // Total number of mints of this NFT     
        pub let mintID: UInt32      // Placing in totalMints, the first minited=1, the second=2, so forth

        pub var copyrightsVerified: UInt8   // Copyright Verified; CHANGE TO ENUM, YES,NO,CLAIM MADE
        pub let copyrightsIncluded: bool    // Copyrights Included

        init(
            title:String, format:String, creator:&{Profile}, collection:&{Collection}, agenct:String,
            isPhysical:bool, bio:String, copyrightsIncluded: bool) {
                self.nftID = nftIDCounter
                DAAM_Agency.nftIDCounter = DAAM_Agency.nftIDCounter + 1
                //self.mintID =
                //self.totalMint = 
                self.title = title
                self.creator = creator
                self.collection = collection
                self.agency = agency
                self.isPhysical = isPhysical
                self.bio = bio
                //self.copyrightsVerified =
                self.copyrightsIncluded = copyrightsIncluded
            }           
        }

        pub resource Art{
            pub let content_format: String
            pub let content: String
            pub let thumbnail_format: String
            pub let thumbnail: String
            pub let about: NFTData           
        }
    }
    init() {
        self.nftIDCounter = 1
    }
}
