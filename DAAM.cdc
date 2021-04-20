Import NonFungibleToken from 0xNFTADDRESS

pub contract DAAM_Agency: NonFungibleToken {
    access(contract) var nftIDCounter
    access(private) enum CopyRightStatus: {
        pub case Fraud
        pub case Claim
        pub case Unverified
        pub case Verified
    }
    access(private) var copyrightsVerified = {UInt32: CopyRightStatus}    
    
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
    access(contract) var CollectionIDCounter: UInt32
    access(contract) var Series_Id: UInt32

    pub struct NFTData {
        pub let title: String       // Title
        pub let format: String      // File format
        pub let creator: &{Profile} // Artist
        // Collection NFT belongs to, nill means belongs to no collection. Collection is on DAAM
        pub let collection: &{Collection} 
        pub let agency: String      // Sold from Gallery or Online // CHANGE TO NFT ??
        pub let isPhysical: Bool    // Does this have a physical counter-part        
        pub let about: String         // About NFT, Blurb or website

        access(contract) let totalMint: UInt32   // Total number of mints of this NFT     
        access(contract) let mintID: UInt32      // Placing in totalMints, the first minited=1, the second=2, so forth

        access(private) let copyrightsIncluded: Bool    // Copyrights Included

        init(
            title:String, format:String, creator:&{Profile}, collection:&{Collection}, agenct:String,
            isPhysical:Bool, about:String, copyrightsIncluded: Bool) {           
                self.title = title!
                self.creator = creator!
                self.collection = collection
                self.agency = agency
                self.isPhysical = isPhysical
                self.about = about                
                self.copyrightsIncluded = copyrightsIncluded // Copyright Variables
            }           
        }

        pub resource Art {
            pub let nftID: UIInt32      // Unique ID
            pub let content_format: String
            pub let content: String
            pub let thumbnail_format: String
            pub let thumbnail: String
            pub let bio: NFTData

            init(bio: NFTData) {
                self.nftID = nftIDCounter!
                DAAM_Agency.nftIDCounter = DAAM_Agency.nftIDCounter + 1     
                self.bio = NFTData!
                // self.about.mintID = DAAM_Agency.[Collection].minted
                // DAAM_Agency.[NFT].minted = DAAM_Agency.[Collection].minted + 1
                // self.about.totalMint = DAAM_Agency.[Collection].totalmint
            }      
        }

        pub resource Collection {
            pub let collectionID: UInt32
            pub let name: String
            pub var collection: @{UInt32: Art}

            init(name: String) {
                self.collectionID = DAAM_Agency.CollectionIDCounter
                self.DAAM_Agency.CollectionIDCounter = DAAM_Agency.CollectionIDCounter + 1
                self.name = name
            }        
        }
    }
    init() {
        self.nftIDCounter = 1
    }
}
