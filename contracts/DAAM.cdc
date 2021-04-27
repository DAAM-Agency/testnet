import NonFungibleToken from 0xf8d6e0586b0a20c7
import Profile from 0xf8d6e0586b0a20c7
import DAAMCopyright from 0xf8d6e0586b0a20c7

// This is an example implementation of a Flow Non-Fungible Token
// It is not part of the official standard but it assumed to be
// very similar to how many NFTs would implement the core functionality.

pub contract DAAM: NonFungibleToken {
    // NonFungibleToken Events
    pub event ContractInitialized()  // Contract Initialization
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    
    // NonFungibleToken Declarations
    pub var totalSupply: UInt64
    
    // Serial Numbers Generation
    access(contract) var collectionIDCounter: UInt64
        
    //access(contract) var seriesIDCounter: UInt64

    /************************************************************/
    // NFT
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64                      // Unique ID
        pub let metadata: {String: String}
        access(self) var copyright: &DAAMCopyright.Copyright
        init(initID: UInt64, metadata: {String: String}) {         
            self.id = initID
            self.metadata = metadata
            self.copyright = DAAMCopyright.setCopyright(copyright: DAAMCopyright.CopyrightStatus.UNVERIFIED)
        }// NFT init       
    }
    /************************************************************/
    // Metadata for NFT,metadata initialization
    pub struct Metadata {
        pub let title: String              // Title
        pub let format: String             // File format
        pub let file: String               // File           
        pub let creator: String//&Profile.ReadOnly   // TODO FIX Artist        
        pub let about: String                // About NFT, Blurb or website
        pub let isPhysical: String             // Does this have a physical counter-part
        pub let series: String      // If, Part of which series  TODO FIX UPGRADE to NFT
        pub let agency: String               // Sold from which Gallery or Online // UPGRADE to NFT
        pub let thumbnail_format: String     // Thumbnail format
        pub let thumbnail: String            // Thumbnail             

        init(title:String, format:String, file: String, creator:String, about:String, physical:String,
            series:String, agency:String, thumbnail_format:String, thumbnail:String) {
            self.title = title
            self.format = format
            self.file = file            
            self.creator = creator            
            self.about = about
            self.isPhysical = physical
            self.series = series
            self.agency = agency
            self.thumbnail_format = thumbnail_format
            self.thumbnail = thumbnail            
        }// Metadata init

        pub fun saveMetadata(): {String:String} {
            let metadata = {
                "title": self.title,
                "format": self.format,
                "file": self.file,
                "creator": self.creator,
                "about": self.about,
                "physical": self.isPhysical,
                "series": self.series,
                "agency": self.agency,
                "thumbnail format": self.thumbnail_format,
                "thumbnail": self.thumbnail
            }
            return metadata
        }// saveMetadata
    }// Metadata
    /************************************************************/
    pub resource Admin {
        pub fun createNewCollection(): @Collection { return <- create Collection ()  }// Create the new collection     

        // borrowSet returns a reference to a set in the DAAM contract so that the admin can call methods on it
        /*pub fun borrowCollection(id: UInt64): &Collection {
            pre { DAAM.collection[setID] != nil: "Cannot borrow Set: The Set doesn't exist" }
            
            // Get a reference to the Set and return it use `&` to indicate the reference to the object and type
            return &DAAM.sets[setID] as &Set
        }*/

        pub fun createNewAdmin(): @Admin { return <-create Admin() }   // createNewAdmin creates a new Admin resource
    }
    /************************************************************/
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        //pub let name: String
        pub let id: UInt64
        pub var name: String
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT} // dictionary of NFT conforming tokens
        
        init () {
            self.id = DAAM.collectionIDCounter
            DAAM.collectionIDCounter = DAAM.collectionIDCounter + 1 as UInt64
            self.ownedNFTs <- {}
            self.name = ""
        } // NFT is a resource type with an `UInt64` ID field
        access(contract) fun setName(name: String) { self.name = name}

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @DAAM.NFT
            let id: UInt64 = token.id            
            let oldToken <- self.ownedNFTs[id] <- token // add the new token to the dictionary which removes the old one
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }
        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }
        // borrowNFT gets a reference to an NFT in the collection so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT { return &self.ownedNFTs[id] as &NonFungibleToken.NFT }
        destroy() { destroy self.ownedNFTs }
    }
    /************************************************************/
    // Resource that an admin or something similar would own to be able to mint new NFTs
	pub resource NFTMinter {
		// mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference 
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: Metadata) {
            let data = metadata.saveMetadata()   	
			var newNFT <- create NFT(initID: DAAM.totalSupply, metadata: data)  // create a new NFT	
			recipient.deposit(token: <-newNFT)  // deposit it in the recipient's account using their reference
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
		}
	}// NFTMinter
    /************************************************************/ // DAAM Top Level    
    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection { return <- create DAAM.Collection() }
    pub fun createNewCollection(name: String): @DAAM.Collection {
        var collection <- create DAAM.Collection()
        collection.setName(name: name)
        return <- collection
    }
   
	init() { // DAAM init
        self.totalSupply         = 0  // Initialize the total supply
        self.collectionIDCounter = 0  // Initialize Collection counter acts as increamental serial number
                
        //self.account.link<&{NonFungibleToken.CollectionPublic}>(/public/DAAMCollection, target: /storage/DAAMCollection)        
        // create a public capability for the collection

        self.account.save<@Admin>(<- create Admin(), to: /storage/DAAMAdmin)
        
        let minter <- create NFTMinter()  // Create a Minter resource and save it to storage
        self.account.save(<-minter, to: /storage/NFTMinter)
        emit ContractInitialized()        // emiter
	}
}
 