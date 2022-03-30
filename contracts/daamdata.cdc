// daam_nft.cdc

import Categories from 0xfd43f9148d4b725d
import Royalty    from 0xfd43f9148d4b725d
/************************************************************************/
pub contract DAAMData {
    // Events
    pub event ContractInitialized()
    pub event AddMetadata(creator: Address, mid: UInt64) // Metadata Added
    pub event RemovedMetadata(mid: UInt64)       // Metadata has been removed by Creator

    // Paths
    pub let metadataPrivatePath   : PublicPath   // Public path that to Metadata Generator: Requires Admin/Agent  or Creator Key
    pub let metadataStoragePath   : StoragePath  // Storage path to Metadata Generator

    // Variables 
    access(contract) var metadataCounterID : UInt64   // The Metadta ID counter for MetadataID.
    access(contract) var copyright : {UInt64: CopyrightStatus} // {MID: CopyrightStatus}

/***********************************************************************/
// Copyright enumeration status // Worst(0) to best(4) as UInt8
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD      // 0 as UInt8
            pub case CLAIM      // 1 as UInt8
            pub case UNVERIFIED // 2 as UInt8
            pub case VERIFIED   // 3 as UInt8
}
/***********************************************************************/
    pub struct Metadata {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let mid       : UInt64   // Metadata ID number
        pub let creator   : Address  // Creator of NFT
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let category  : [Categories.Category]
        pub let data      : String   // JSON see metadata.json all data ABOUT the NFT is stored here
        pub let thumbnail : String   // JSON see metadata.json all thumbnails are stored here
        pub let file      : String   // JSON see metadata.json all NFT file formats are stored here
        
        init(creator: Address, series: UInt64, categories: [Categories.Category], data: String, thumbnail: String, file: String, counter: &Metadata?) {
            if counter != nil {
                if counter!.counter >= series && series != 0 { panic("Metadata setting incorrect.") }
            }
            
            // Init all NFT setting
            // initializing Metadata ID, self.mid
            if counter == nil {
                DAAMData.metadataCounterID = DAAMData.metadataCounterID + 1
                self.mid = DAAMData.metadataCounterID
            } else {
                self.mid = counter!.mid // init MID with counter
            }
            self.creator   = creator   // creator of NFT
            self.series    = series    // total prints
            self.counter = counter == nil ? 1 : counter!.counter + 1 // current print of total prints
            self.category  = categories
            self.data      = data      // data,about,misc page
            self.thumbnail = thumbnail // thumbnail are stored here
            self.file      = file      // NFT data is stored here
        }
    }
/************************************************************************/
pub resource interface MetadataGeneratorMint {
    pub fun generateMetadata(minter: PublicAccount, mid: UInt64) : @MetadataHolder  // Used to generate a Metadata either new or one with an incremented counter
}
/************************************************************************/
pub resource interface MetadataGeneratorPublic {
    pub fun getMetadata(): {UInt64 : Metadata} 
}
/************************************************************************/
// Verifies each Metadata gets a Metadata ID, and stores the Creators' Metadatas'.
pub resource MetadataGenerator: MetadataGeneratorPublic, MetadataGeneratorMint {
        // Variables
        priv var metadata : {UInt64 : Metadata} // {MID : Metadata (Struct)}
        priv let grantee: Address

        init(_ grantee: Address) {
            self.metadata = {}  // Init Metadata
            self.grantee  = grantee
        }

        // addMetadata: Used to add a new Metadata. This sets up the Metadata to be approved by the Admin. Returns the new mid.
        pub fun addMetadata(creator: AuthAccount, series: UInt64, categories: [Categories.Category], data: String, thumbnail: String, file: String): UInt64 {
            pre { self.grantee == creator.address : "Permission Denied" }

            let metadata = Metadata(creator: creator.address, series: series, categories: categories, data: data, thumbnail: thumbnail,
                file: file, counter: nil) // Create Metadata
            let mid = metadata.mid
            self.metadata.insert(key: mid, metadata) // Save Metadata
            DAAMData.copyright.insert(key: mid, CopyrightStatus.UNVERIFIED) // default copyright setting

            log("Metadata Generatated ID: ".concat(mid.toString()) )
            emit AddMetadata(creator: creator.address, mid: mid)
            return mid
        }

        // RemoveMetadata uses deleteMetadata to delete the Metadata.
        // But when deleting a submission the request must also be deleted.
        pub fun removeMetadata(creator: AuthAccount, mid: UInt64) {
            pre {
                self.grantee == self.owner?.address!       : "Permission Denied"
                self.metadata[mid] != nil : "No Metadata entered"
            }
            self.deleteMetadata(mid: mid)  // Delete Metadata
        }

        // Used to remove Metadata from the Creators metadata dictionary list.
        priv fun deleteMetadata(mid: UInt64) {
            self.metadata.remove(key: mid) // Metadata removed. Metadata Template has reached its max count (series)
            DAAMData.copyright.remove(key:mid) // remove metadata copyright            
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)
        }
        // Remove Metadata as Resource MetadataHolder. MetadataHolder + Request = NFT.
        // The MetadataHolder will be destroyed along with a matching Request (same MID) in order to create the NFT
        pub fun generateMetadata(minter: PublicAccount, mid: UInt64) : @MetadataHolder {
            pre {
                self.grantee == self.owner?.address!            : "Permission Denied"
                self.metadata[mid] != nil : "No Metadata entered"
            }            
                        
            let mh <- create MetadataHolder(metadata: self.metadata[mid]!) // Create current Metadata
            // Verify Metadata Counter (print) is not last, if so delete Metadata
            if self.metadata[mid]!.counter == self.metadata[mid]?.series! && self.metadata[mid]?.series! != 0 {
                self.deleteMetadata(mid: mid) // Remove metadata template
            } else { // if not last, print
                let new_metadata = Metadata(                  // Prep next Metadata
                    creator: self.metadata[mid]?.creator!, series: self.metadata[mid]?.series!, categories: self.metadata[mid]?.category!,
                    data: self.metadata[mid]?.data!, thumbnail: self.metadata[mid]?.thumbnail!, file: self.metadata[mid]?.file!, counter: &self.metadata[mid] as &Metadata
                )
                log("Generate Metadata: ".concat(new_metadata.mid.toString()) )
                self.metadata[mid] = new_metadata // Update to new incremented (counter) Metadata
            }
            return <- mh // Return current Metadata  
        }

        pub fun getMIDs(): [UInt64] { // Return specific MIDs of Creator
            return self.metadata.keys
        }

        pub fun getMetadata(): {UInt64: Metadata} {
            return self.metadata
        }

        destroy() {}
}
/************************************************************************/
// MetadataHolder is a container for Metadata. It is where Metadata is stored to become
// an argument for NFT
    pub resource MetadataHolder {        
        access(contract) var metadata: Metadata
        init (metadata: Metadata) {
            pre { metadata != nil : "Metadata can not be Empty." }              
            self.metadata = metadata // Store Metadata
        }
        pub fun getMID(): UInt64 { return self.metadata.mid } // get MID
    }
/************************************************************************/
    // Public DAAMData functions

    pub fun getCopyright(mid: UInt64): CopyrightStatus? {
        return self.copyright[mid]
    }
    
    init()
    {
        // Paths
        self.metadataPrivatePath   = /public/DAAM_SubmitNFT
        self.metadataStoragePath   = /storage/DAAM_SubmitNFT
        // Initialize variables
        self.copyright = {}
        //self.metadata  = {}
        //self.metadataCap = {}
        // Counter varibbles
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        emit ContractInitialized()
	}
}
