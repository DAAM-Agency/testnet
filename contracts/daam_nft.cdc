// daam_nft.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import FungibleToken    from 0xee82856bf20e2aa6 
import Profile          from 0x192440c99cb17282
import Categories       from 0xfd43f9148d4b725d
import DAAM_Metadata    from 0xfd43f9148d4b725d
/************************************************************************/
pub contract DAAM: NonFungibleToken {
    // Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?) // Collection Wallet, used to withdraw NFT
    pub event Deposit(id: UInt64,   to: Address?)  // Collection Wallet, used to deposit NFT
    // Events
    pub event NewAdmin(admin  : Address)         // A new Admin has been added. Accepted Invite
    pub event NewAgent(agent  : Address)         // A new Agent has been added. Accepted Invite
    pub event NewMinter(minter: Address)         // A new Minter has been added. Accepted Invite
    pub event NewCreator(creator: Address)       // A new Creator has been added. Accepted Invite
    pub event AdminInvited(admin  : Address)     // Admin has been invited
    pub event AgentInvited(agent  : Address)     // Agent has been invited
    pub event CreatorInvited(creator: Address)   // Creator has been invited
    pub event MinterSetup(minter: Address)       // Minter has been invited
    
    pub event MintedNFT(id: UInt64)              // Minted NFT
    pub event ChangedCopyright(metadataID: UInt64) // Copyright has been changed to a MID 
    pub event ChangeAgentStatus(agent: Address, status: Bool)     // Agent Status has been changed by Admin
    pub event ChangeCreatorStatus(creator: Address, status: Bool) // Creator Status has been changed by Admin/Agemnt
    pub event ChangeMinterStatus(minter: Address, status: Bool)    // Minter Status has been changed by Admin
    pub event AdminRemoved(admin: Address)       // Admin has been removed
    pub event AgentRemoved(agent: Address)       // Agent has been removed by Admin
    pub event CreatorRemoved(creator: Address)   // Creator has been removed by Admin
    pub event MinterRemoved(minter: Address)     // Minter has been removed by Admin
    pub event RemovedAdminInvite()               // Admin invitation has been rescinded
    // Paths
    pub let collectionPublicPath  : PublicPath   // Public path to Collection
    pub let collectionStoragePath : StoragePath  // Storage path to Collection
    pub let metadataPrivatePath   : PublicPath   // Public path that to Metadata Generator: Requires Admin/Agent  or Creator Key
    pub let metadataStoragePath   : StoragePath  // Storage path to Metadata Generator
    pub let adminPrivatePath      : PrivatePath  // Private path to Admin 
    pub let adminStoragePath      : StoragePath  // Storage path to Admin 
    pub let minterPrivatePath     : PrivatePath  // Private path to Minter
    pub let minterStoragePath     : StoragePath  // Storage path to Minter
    pub let creatorPrivatePath    : PrivatePath  // Private path to Creator
    pub let creatorStoragePath    : StoragePath  // Storage path to Creator
    pub let requestPrivatePath    : PrivatePath  // Private path to Request
    pub let requestStoragePath    : StoragePath  // Storage path to Request
    // Variables
    pub var totalSupply : UInt64 // the total supply of NFTs, also used as counter for token ID
    access(contract) var remove  : {Address: Address} // Requires 2 Admins to remove an Admin, the Admins are stored here. {Voter : To Remove}
    access(contract) var admins  : {Address: Bool}    // {Admin Address : status}  Admin address are stored here
    access(contract) var agents  : {Address: Bool}    // {Agents Address : status} Agents address are stored here // preparation for V2
    access(contract) var minters : {Address: Bool}    // {Minters Address : status} Minter address are stored here // preparation for V2
    access(contract) var creators: {Address: Bool}    // {Creator Address : status} Creator address are stored here
    access(contract) var metadata: {UInt64 : Bool}    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var metadataCap: {Address : Capability<&MetadataGenerator{MetadataGeneratorPublic}> }    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var request : @{UInt64: Request} // {MID : @Request } Request are stored here by MID
    access(contract) var copyright: {UInt64: CopyrightStatus} // {NFT.id : CopyrightStatus} Get Copyright Status by Token ID
    // Variables 
    access(contract) var metadataCounterID : UInt64   // The Metadta ID counter for MetadataID.
    access(contract) var newNFTs: [UInt64]    // A list of newly minted NFTs. 'New' is defined as 'never sold'. Age is Not a consideration.
    pub let agency : Address     // DAAM Ageny Address
/************************************************************************/
    pub resource interface INFT {
        pub let id       : UInt64   // Token ID, A unique serialized number
        pub let metadata : Metadata // Metadata of NFT
        pub let royality : {Address : UFix64} // Where all royalities
    }
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT, INFT {
        pub let id       : UInt64   // Token ID, A unique serialized number
        pub let metadata : Metadata // Metadata of NFT
        pub let royality : {Address : UFix64} // Where all royalities are stored {Address : percentage} Note: 1.0 = 100%

        init(metadata: @MetadataHolder, request: &Request) {
            pre { metadata.metadata.mid == request.mid : "Metadata and Request have different MIDs. They are not meant for each other."}
            DAAM.totalSupply = DAAM.totalSupply + 1 // Increment total supply
            self.id = DAAM.totalSupply              // Set Token ID with total supply
            self.royality = request.royality        // Save Request which are the royalities.  
            self.metadata = metadata.metadata       // Save Metadata from Metadata Holder
            destroy metadata                        // Destroy no loner needed container Metadata Holder
        }

        pub fun getCopyright(): CopyrightStatus { // Get current NFT Copyright status
            return DAAM.copyright[self.id]! // return copyright status
        }
    }
/************************************************************************/
// Wallet Public standards. For Public access only
pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT) // Used to deposit NFT
    pub fun getIDs(): [UInt64]                    // Get NFT Token IDs
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT // Get NFT as NonFungibleToken.NFT

    pub fun getAlbum(): {String: CollectionData}      // Get collections
    pub fun borrowDAAM(id: UInt64): &DAAM.NFT         // Get NFT as DAAM.NFT
    pub fun findCollection(tokenID: UInt64): [String] // Find collections containing TokenID
}
/************************************************************************/
// Structure to store collection data
pub struct CollectionData {
    pub var ids : [UInt64]  // List of TokenIDs in collection
    pub var sub_collection: [String] // List of sub-collections

    init() {
        self.ids  = []
        self.sub_collection = []
    }
}
/************************************************************************/
// Standand Flow Collection Wallet
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens. NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs  : @{UInt64: NonFungibleToken.NFT}  // Store NFTs via Token ID
        pub var album : {String: CollectionData } // {name : CollectionData }
                        
        init() {
            self.ownedNFTs <- {} // List of owned NFTs
            self.album = {}
        } 

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            self.removeFromCollections(tokenID: withdrawID)
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT") // Get NFT
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @DAAM.NFT // Get NFT as DAAM.GFT
            let id: UInt64 = token.id        // Save Token ID
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token   // Store NFT
            emit Deposit(id: id, to: self.owner?.address) 
            destroy oldToken                              // destroy place holder
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }        

        // borrowNFT gets a reference to an NonFungibleToken.NFT in the collection.
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
        }
        // borrowDAAM gets a reference to an DAAM.NFT in the album.
        pub fun borrowDAAM(id: UInt64): &DAAM.NFT {
            pre { self.ownedNFTs[id] != nil : "Your Collection is empty." }
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT // Get reference to NFT
            return ref as! &DAAM.NFT                                    // return NFT Reference
        }
        // Create an album name
        pub fun createCollection(name: String) {
            pre  { !self.album.containsKey(name) : "Collection already exist." }
            post { self.album.containsKey(name)  : "Internal Error: Create Collection" }
            self.album.insert(key: name, CollectionData() )
            log("Collection Created: ".concat(name))
            log(self.album)
        } 
        // Remove a album name
        pub fun removeCollection(name: String) {
            pre  { self.album.containsKey(name) : "Collection: ".concat(name).concat(" does not exist.") }
            post { !self.album.containsKey(name)  : "Internal Error: Remove Collection" }
            self.album.remove(key: name)
            log("Collection Removed")
        }

        // Add a tokenID to collection
        pub fun addToCollection(name: String, tokenID: UInt64) {
            pre  {
                self.album.containsKey(name)            : "Collection: ".concat(name).concat(" does not exist.")
                self.ownedNFTs.containsKey(tokenID)     : "Token ID: ".concat(tokenID.toString()).concat(" is nor part of your Collection(s).")
                !self.album[name]!.ids.contains(tokenID): "Token ID: ".concat(tokenID.toString()).concat(" already in Collection: ").concat(name)
            }
            self.album[name]!.ids.append(tokenID)
        }

        // Remove a tokenID from a collection
        pub fun removeFromCollection(name: String, tokenID: UInt64) {
            pre  {
                self.album.containsKey(name)            : "Collection: ".concat(name).concat(" does not exist.")
                self.ownedNFTs.containsKey(tokenID)     : "Token ID: ".concat(tokenID.toString()).concat(" is nor part of your Collection(s).")
                self.album[name]!.ids.contains(tokenID) : "Token ID: ".concat(tokenID.toString()).concat(" already in Collection: ").concat(name)
            }            
            var elm = self.findIndex(name: name, tokenID: tokenID)
            self.album[name]!.ids.remove(at: elm!)
        }

        // Add a sub-collection to collection
        pub fun addSubCollection(name: String, collection: String) {
            pre  {
                self.album.containsKey(name)       : "Collection: ".concat(name).concat(" does not exist.")
                self.album.containsKey(collection) : "Collection: ".concat(collection).concat(" does not exist.")
                !self.album[name]!.sub_collection.contains(collection) : "Collection: ".concat(collection).concat(" already in this Collection.")
            }
            self.album[name]!.sub_collection.append(name)
        }

        // Remove a sub-collection from a collection
        pub fun removeSubCollection(name: String, collection: String) {
            pre  {
                self.album.containsKey(name)       : "Collection: ".concat(name).concat(" does not exist.")
                self.album.containsKey(collection) : "Collection: ".concat(collection).concat(" does not exist.")
                self.album[name]!.sub_collection.contains(collection) : "Collection: ".concat(collection).concat(" does not exist in this Collection.")
            }
            var counter = 0
            for c in self.album[name]!.sub_collection {
                if c == collection { break }
                counter = counter + 1
            }  
            self.album[name]!.sub_collection.remove(at: counter)
        }

        // Find collection(s) with selected TokenID
        pub fun findCollection(tokenID: UInt64): [String] {
            pre { self.ownedNFTs[tokenID] != nil : "Token ID: ".concat(tokenID.toString()).concat(" is not part of your Collection(s).") }
            var list: [String] = []
            for name in self.album.keys {
                if self.findIndex(name: name, tokenID: tokenID) != nil {
                    list.append(name)                 
                }
            }
            return list
        }

        // Remove a tokenID from all collection
        pub fun removeFromCollections(tokenID: UInt64) {            
            let list = self.findCollection(tokenID: tokenID)
            for name in list {
                self.removeFromCollection(name: name, tokenID: tokenID)
            }            
        }

        // Get all collections
        pub fun getAlbum(): {String: CollectionData} {
            log(self.album)
            return self.album
        }

        // Find index of TokenID in collection
        priv fun findIndex(name: String, tokenID: UInt64): UInt64? {
            var counter = 0 as UInt64
            for id in self.album[name]!.ids {                
                if id == tokenID { return counter }
                counter = counter + 1
            }
            return nil       
        }              

        destroy() { destroy self.ownedNFTs } // Destructor
    }
/************************************************************************/
    // Public DAAM functions
    
    // Create an new Collection to store NFTs
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        post { result.getIDs().length == 0: "The created collection must be empty!" }
        return <- create Collection() // Return Collection Resource
    }

    // Create an new Collection to store NFTs
    pub fun createDAAMCollection(): @DAAM.Collection {
        post { result.getIDs().length == 0: "The created DAAM collection must be empty!" }
        return <- create DAAM.Collection() // Return Collection Resource
    }

/************************************************************************/
// Init DAAM Contract variables
    
    init(agency: Address)
    {
        // Paths
        self.collectionPublicPath  = /public/DAAM_Collection
        self.collectionStoragePath = /storage/DAAM_Collection
        // Internal  variables
        self.agency = agency
        // Initialize variables
        self.metadata  = {}
        self.metadataCap = {}
        self.newNFTs   = []
        // Counter varibbles
        self.totalSupply         = 0  // Initialize the total supply of NFTs

        emit ContractInitialized()
	}
}
