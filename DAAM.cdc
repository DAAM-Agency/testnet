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
    access(contract) var NFT_Id: UInt32
    access(contract) var Collection_Id: UInt32
    access(contract) var Series_Id: UInt32
