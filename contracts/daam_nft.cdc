// daam_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken    from 0x9a0766d93b6608b7 
import Profile          from 0xba1132bc08f82fe2
import Categories       from 0xa4ad5ea5c0bd2fba

/************************************************************************/
pub contract DAAM_V8: NonFungibleToken {
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
    pub event AddMetadata(creator: Address, mid: UInt64) // Metadata Added
    pub event MintedNFT(id: UInt64)              // Minted NFT
    pub event ChangedCopyright(metadataID: UInt64) // Copyright has been changed to a MID 
    pub event ChangeAgentStatus(agent: Address, status: Bool)     // Agent Status has been changed by Admin
    pub event ChangeCreatorStatus(creator: Address, status: Bool) // Creator Status has been changed by Admin/Agemnt
    pub event ChangeMinterStatus(minter: Address, status: Bool)    // Minter Status has been changed by Admin
    pub event AdminRemoved(admin: Address)       // Admin has been removed
    pub event AgentRemoved(agent: Address)       // Agent has been removed by Admin
    pub event CreatorRemoved(creator: Address)   // Creator has been removed by Admin
    pub event MinterRemoved(minter: Address)     // Minter has been removed by Admin
    pub event RequestAccepted(mid: UInt64)       // Royalty rate has been accepted 
    pub event RemovedMetadata(mid: UInt64)       // Metadata has been removed by Creator
    pub event RemovedAdminInvite()               // Admin invitation has been rescinded
    // Paths
    pub let collectionPublicPath  : PublicPath   // Public path to Collection
    pub let collectionStoragePath : StoragePath  // Storage path to Collection
    pub let metadataPublicPath    : PublicPath   // Public path that to Metadata Generator: Requires Admin/Agent  or Creator Key
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
    pub let agency : Address     // DAAM_V8 Ageny Address
/***********************************************************************/
// Copyright enumeration status // Worst(0) to best(4) as UInt8
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD      // 0 as UInt8
            pub case CLAIM      // 1 as UInt8
            pub case UNVERIFIED // 2 as UInt8
            pub case VERIFIED   // 3 as UInt8
}
/***********************************************************************/
// Used to make requests for royality. A resource for Neogoation of royalities.
// When both parties agree on 'royality' the Request is considered valid aka isValid() = true and
// Request manage the royality rate
// Accept Default are auto agreements
pub resource Request {
    access(contract) let mid       : UInt64                // Metadata ID number is stored
    access(contract) var royality  : {Address : UFix64}    // current royality neogoation.
    access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(mid: UInt64) {
        self.mid       = mid             // Get Metadata ID
        DAAM_V8.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
        self.royality  = {}              // royality is initialized
        self.agreement = [false, false]  // [Agency/Admin, Creator] are both set to disagree by default
    }

    pub fun getMID(): UInt64 { return self.mid }  // return Metadata ID
    
    // Accept Default royality. Skip Neogations.
    access(contract) fun acceptDefault(royality: {Address:UFix64} ) {
        self.royality = royality        // get royality
        self.agreement = [true, true]   // set agreement status to Both parties Agreed
    }

    // If both parties agree (Creator & Admin) return true
    pub fun isValid(): Bool { return self.agreement[0]==true && self.agreement[1]==true }
}    
/***********************************************************************/
// Used to create Request Resources. Metadata ID is passed into Request.
// Request handle Royalities, and Negoatons.
pub resource RequestGenerator {
    priv let grantee: Address

    init(_ grantee: Address) { self.grantee = grantee }

    // Accept the default Request. No Neogoation is required.
    // Percentages are between 10% - 30%
    pub fun acceptDefault(mid: UInt64, metadataGen: &MetadataGenerator{MetadataGeneratorPublic}, percentage: UFix64) {
        pre {
            self.grantee == self.owner!.address     : "Permission Denied"
            metadataGen.getMIDs().contains(mid)  : "Wrong MID"
            DAAM_V8.creators.containsKey(self.grantee) : "You are not a Creator"
            DAAM_V8.creators[self.grantee]!            : "Your Creator account is Frozen."
            percentage >= 0.01 && percentage <= 0.3  : "Percentage must be inbetween 10% to 30%."
        }

        var royality = {DAAM_V8.agency: (0.1 * percentage) }  // get Agency percentage, Agency takes 10% of Creator
        royality.insert(key: self.grantee, (0.9 * percentage) ) // get Creator percentage

        let request <-! create Request(mid: mid) // get request
        request.acceptDefault(royality: royality)          // append royality rate

        let old <- DAAM_V8.request.insert(key: mid, <-request) // advice DAAM_V8 of request
        destroy old // destroy place holder
        
        log("Request Accepted, MID: ".concat(mid.toString()) )
        emit RequestAccepted(mid: mid)
    }
}
/************************************************************************/
    pub struct MetadataHolder {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let creator   : Address  // Creator of NFT
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let category  : [Categories.Category]
        pub let data      : String   // JSON see metadata.json all data ABOUT the NFT is stored here
        pub let thumbnail : String   // JSON see metadata.json all thumbnails are stored here
        pub let file      : String   // JSON see metadata.json all NFT file formats are stored here
        
        init(creator: Address, series: UInt64, categories: [Categories.Category], data: String, thumbnail: String, file: String, counter: UInt64)
        {
            self.creator   = creator   // creator of NFT
            self.series    = series    // total prints
            self.counter   = counter   // current print of total prints
            self.category  = categories
            self.data      = data      // data,about,misc page
            self.thumbnail = thumbnail // thumbnail are stored here
            self.file      = file      // NFT data is sto            
        }
    }
/************************************************************************/
    pub resource Metadata {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let mid       : UInt64   // Metadata ID number
        pub let creator   : Address  // Creator of NFT
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let category  : [Categories.Category]
        pub let data      : String   // JSON see metadata.json all data ABOUT the NFT is stored here
        pub let thumbnail : String   // JSON see metadata.json all thumbnails are stored here
        pub let file      : String   // JSON see metadata.json all NFT file formats are stored here
        
        init(creator: Address?, series: UInt64?, categories: [Categories.Category]?, data: String?, thumbnail: String?, file: String?, counter: &Metadata?)
        {
            pre {
                // Increment Metadata Counter Arguments are correct
                (creator==nil && series==nil && categories==nil && data==nil
                && thumbnail==nil && file==nil && counter != nil)
                || // or
                // New Metadata (Counter = 1) Arguments are correct
                (creator!=nil && series!=nil && categories!=nil && data!=nil
                && thumbnail!=nil && file!=nil && counter == nil)
            }

            // initializing Metadata
            if counter == nil {
                DAAM_V8.metadataCounterID = DAAM_V8.metadataCounterID + 1
                self.mid       = DAAM_V8.metadataCounterID // init MID with counter
                self.creator   = creator!               // creator of NFT
                self.series    = series!                // total prints
                self.counter   = 1                      // current print of total prints
                self.category  = categories!            // categories 
                self.data      = data!                  // data,about,misc page
                self.thumbnail = thumbnail!             // thumbnail are stored here
                self.file      = file!                  // NFT data is stored here
            } else {
                self.mid       = counter!.mid          // init MID with counter
                self.creator   = counter!.creator      // creator of NFT
                self.series    = counter!.series       // total prints
                self.counter   = counter!.counter + 1  // current print of total prints
                self.category  = counter!.category     // categories 
                self.data      = counter!.data         // data,about,misc page
                self.thumbnail = counter!.thumbnail    // thumbnail are stored here
                self.file      = counter!.file         // NFT data is stored here
                // Error checking; Re-prints do not excede series limit or is Unlimited prints
                if self.counter > self.series && self.series != 0 { panic("Metadata setting incorrect.") }
            }
        }

        pub fun getHolder(): MetadataHolder {
            return MetadataHolder(creator: self.creator, series: self.series, categories: self.category,
            data: self.data, thumbnail: self.thumbnail, file: self.file, counter: self.counter)
        }
    }
/************************************************************************/
pub resource interface MetadataGeneratorMint {
    // Used to generate a Metadata either new or one with an incremented counter
    // Requires a Minters Key to generate MinterAccess
    pub fun generateMetadata(minter: @MinterAccess, mid: UInt64) : @Metadata
}
/************************************************************************/
pub resource interface MetadataGeneratorPublic {
    pub fun getMIDs(): [UInt64]
    pub fun viewMetadata(mid: UInt64): MetadataHolder?
    pub fun viewMetadatas(): [MetadataHolder]
}
/************************************************************************/
// Verifies each Metadata gets a Metadata ID, and stores the Creators' Metadatas'.
pub resource MetadataGenerator: MetadataGeneratorPublic, MetadataGeneratorMint {
        // Variables
        priv var metadata : @{UInt64 : Metadata} // {MID : Metadata Resource}
        priv let grantee: Address

        init(_ grantee: Address) {
            self.metadata <- {}  // Init Metadata
            self.grantee = grantee
            DAAM_V8.metadataCap.insert(key: self.grantee, getAccount(self.grantee).getCapability<&MetadataGenerator{MetadataGeneratorPublic}>(DAAM_V8.metadataPublicPath))
        }

        // addMetadata: Used to add a new Metadata. This sets up the Metadata to be approved by the Admin. Returns the new mid.
        pub fun addMetadata(series: UInt64, categories: [Categories.Category], data: String, thumbnail: String, file: String): UInt64 {
            pre{
                self.grantee == self.owner!.address            : "Permission Denied"
                DAAM_V8.creators.containsKey(self.grantee) : "You are not a Creator"
                DAAM_V8.creators[self.grantee]!            : "Your Creator account is Frozen."
            }
            let metadata <- create Metadata(creator: self.grantee, series: series, categories: categories, data: data, thumbnail: thumbnail,
                file: file, counter: nil) // Create Metadata
            let mid = metadata.mid
            let old <- self.metadata[mid] <- metadata // Save Metadata
            destroy old
            DAAM_V8.metadata.insert(key: mid, false)   // a metadata ID for Admin approval, currently unapproved (false)
            DAAM_V8.copyright.insert(key: mid, CopyrightStatus.UNVERIFIED) // default copyright setting

            // DAAM_V8.metadata[mid] = true // TODO REMOVE AUTO-APPROVE AFTER DEVELOPEMNT

            log("Metadata Generatated ID: ".concat(mid.toString()) )
            emit AddMetadata(creator: self.grantee, mid: mid)
            return mid
        }

        // RemoveMetadata uses clearMetadata to delete the Metadata.
        // But when deleting a submission the request must also be deleted.
        pub fun removeMetadata(mid: UInt64) {
            pre {
                self.grantee == self.owner!.address       : "Permission Denied"
                DAAM_V8.creators.containsKey(self.grantee) : "You are not a Creator"
                DAAM_V8.creators[self.grantee]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
            }
            let old_meta <- self.clearMetadata(mid: mid)  // Delete Metadata
            destroy old_meta

            let old_request <- DAAM_V8.request.remove(key: mid)  // Get Request
            destroy old_request // Delete Request
        }

        // Used to remove Metadata from the Creators metadata dictionary list.
        priv fun clearMetadata(mid: UInt64): @Metadata {            
            DAAM_V8.metadata.remove(key: mid) // Metadata removed from DAAM_V8. Logging no longer neccessary
            DAAM_V8.copyright.remove(key:mid) // remove metadata copyright            
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)

            return <- self.metadata.remove(key: mid)! // Metadata removed. Metadata Template has reached its max count (series)
        }
        // Remove Metadata as Resource. Metadata + Request = NFT.
        // The Metadata will be destroyed along with a matching Request (same MID) in order to create the NFT
        pub fun generateMetadata(minter: @MinterAccess, mid: UInt64) : @Metadata {
            pre {
                self.grantee == self.owner!.address     : "Permission Denied"
                minter.validate()                       : "Permission Denied"
                DAAM_V8.creators.containsKey(self.grantee) : "You are not a Creator"
                DAAM_V8.creators[self.grantee]!            : "Your Creator account is Frozen."
                
                self.metadata[mid] != nil : "No Metadata entered"
                DAAM_V8.metadata[mid] != nil : "This already has been published."
                DAAM_V8.metadata[mid]!       : "Your Submission was Rejected."
            }
            destroy minter

            // Create Metadata with incremented counter/print
            let mRef = &self.metadata[mid] as &Metadata

            // Verify Metadata Counter (print) is not last, if so delete Metadata
            if mRef.counter < mRef.series! && mRef.series! != 0 {            
                let new_metadata <- create Metadata(creator: nil,series: nil,categories: nil,data: nil,thumbnail: nil,file: nil, counter: mRef!)
                let orig_metadata <- self.metadata[mid] <- new_metadata // Update to new incremented (counter) Metadata
                return <- orig_metadata! // Return current Metadata                 
            } else { // if not last, print
                let orig_metadata <- self.clearMetadata(mid: mid) // Remove metadata template
                return <- orig_metadata! // Return current Metadata  
            }
        }

        pub fun getMIDs(): [UInt64] { // Return specific MIDs of Creator
            return self.metadata.keys
        }

        pub fun viewMetadata(mid: UInt64): MetadataHolder? {
            pre { self.metadata[mid] != nil : "Invalid MID" }
            let mRef = &self.metadata[mid] as &Metadata
            return mRef.getHolder()
        }

        pub fun viewMetadatas: [MetadataHolder] {
            pre { self.metadata[mid] != nil : "Invalid MID" }
            var list: [MetadataHolder]
            let mRef = &self.metadata as &Metadata
            return mRef.getHolder()
        }

        pub fun viewMetadatas(): [MetadataHolder] {
            var list: [MetadataHolder] = []
            for m in self.metadata.keys {
                let mRef = &self.metadata[m] as &Metadata
                list.append(mRef.getHolder() )
            } 
            return list
        }

        destroy() { destroy self.metadata } 
}
/************************************************************************/
    pub resource interface INFT {
        pub let id       : UInt64   // Token ID, A unique serialized number
        pub let mid      : UInt64   // Token ID, A unique serialized number
        pub let metadata : MetadataHolder // Metadata of NFT
        pub let royality : {Address : UFix64} // Where all royalities
    }
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT, INFT {
        pub let id       : UInt64   // Token ID, A unique serialized number
        pub let mid      : UInt64   // Metadata ID, A unique serialized number
        pub let metadata : MetadataHolder // Metadata of NFT
        pub let royality : {Address : UFix64} // Where all royalities are stored {Address : percentage} Note: 1.0 = 100%

        init(metadata: @Metadata, request: &Request) {
            pre { metadata.mid == request.mid : "Metadata and Request have different MIDs. They are not meant for each other."}
            
            DAAM_V8.totalSupply = DAAM_V8.totalSupply + 1 // Increment total supply
            self.id          = DAAM_V8.totalSupply     // Set Token ID with total supply
            self.mid         = metadata.mid         // Set Metadata ID
            self.royality    = request.royality     // Save Request which are the royalities.  
            self.metadata    = metadata.getHolder() // Save Metadata from Metadata Holder
            destroy metadata                        // Destroy no loner needed container Metadata Holder
        }

        pub fun getCopyright(): CopyrightStatus { // Get current NFT Copyright status
            return DAAM_V8.copyright[self.id]! // return copyright status
        }
    }
/************************************************************************/
// Wallet Public standards. For Public access only
pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT) // Used to deposit NFT
    pub fun getIDs(): [UInt64]                    // Get NFT Token IDs
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT // Get NFT as NonFungibleToken.NFT

    pub fun getAlbum(): {String: CollectionData}      // Get collections
    pub fun borrowDAAM(id: UInt64): &DAAM_V8.NFT         // Get NFT as DAAM_V8.NFT
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
            let token <- token as! @DAAM_V8.NFT // Get NFT as DAAM_V8.GFT
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
        // borrowDAAM gets a reference to an DAAM_V8.NFT in the album.
        pub fun borrowDAAM(id: UInt64): &DAAM_V8.NFT {
            pre { self.ownedNFTs[id] != nil : "Your Collection is empty." }
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT // Get reference to NFT
            return ref as! &DAAM_V8.NFT                                    // return NFT Reference
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
// Agent interface. List of all powers belonging to the Agent
    pub resource interface Agent 
    {
        pub var status: Bool // the current status of the Admin

        pub fun inviteCreator(_ creator: Address)                   // Admin invites a new creator       
        pub fun changeCreatorStatus(creator: Address, status: Bool) // Admin or Agent change Creator status        
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) // Admin or Agenct can change MID copyright status
        pub fun changeMetadataStatus(mid: UInt64, status: Bool)     // Admin or Agent can change Metadata Status
        pub fun removeCreator(creator: Address)                     // Admin or Agent can remove CAmiRajpal@hotmail.cometadata Status
        pub fun newRequestGenerator(): @RequestGenerator            // Create Request Generator
        pub fun getMetadataStatus(): {UInt64:Bool}                  // Returns the Metadata status {MID : Status}
    }
/************************************************************************/
// The Admin Resource deletgates permissions between Founders and Agents
pub resource Admin: Agent
{
        pub var status: Bool       // The current status of the Admin
        priv let grantee: Address

        init(_ admin: Address) {
            self.status  = true      // Default Admin status: True
            self.grantee = admin
        }

        // Used only when genreating a new Admin. Creates a Resource Generator for Negoiations.
        pub fun newRequestGenerator(): @RequestGenerator {
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status : "You're no longer a have Access."
            }
            return <- create RequestGenerator(self.grantee) // return new Request
        }

        pub fun inviteAdmin(newAdmin: Address) {     // Admin invite a new Admin
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                    : "You're no longer a have Access."
                DAAM_V8.creators[newAdmin] == nil : "A Admin can not use the same address as an Creator."
                DAAM_V8.agents[newAdmin] == nil   : "A Admin can not use the same address as an Agent."
                DAAM_V8.admins[newAdmin] == nil   : "They're already sa DAAM_V8 Admin!!!"
                Profile.check(newAdmin) : "You can't be a DAAM_V8 Admin without a Profile! Go make one Fool!!"
            }
            post { DAAM_V8.admins[newAdmin] == false : "Illegal Operaion: inviteAdmin" }

            DAAM_V8.admins.insert(key: newAdmin, false) // Admin account is setup but not active untill accepted.
            log("Sent Admin Invitation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteAgent(_ agent: Address) {    // Admin ivites new Agent
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                 : "You're no longer a have Access."
                DAAM_V8.admins[agent] == nil   : "A Agent can not use the same address as an Admin."
                DAAM_V8.creators[agent] == nil : "A Agent can not use the same address as an Creator."
                DAAM_V8.agents[agent] == nil   : "They're already a DAAM_V8 Agent!!!"
                Profile.check(agent) : "You can't be a DAAM_V8 Admin without a Profile! Go make one Fool!!"
            }
            post { DAAM_V8.agents[agent] == false : "Illegal Operaion: inviteAdmin" }

            DAAM_V8.agents.insert(key: agent, false ) // Agent account is setup but not active untill accepted.
            log("Sent Agent Invitation: ".concat(agent.toString()) )
            emit AgentInvited(agent: agent)         
        }

        pub fun inviteCreator(_ creator: Address) {    // Admin or Agent invite a new creator
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                   : "You're no longer a have Access."
                DAAM_V8.admins[creator]   == nil : "A Creator can not use the same address as an Admin."
                DAAM_V8.agents[creator]   == nil : "A Creator can not use the same address as an Agent."
                DAAM_V8.creators[creator] == nil : "They're already a DAAM_V8 Creator!!!"
                Profile.check(creator) : "You can't be a DAAM_V8 Creator without a Profile! Go make one Fool!!"
            }
            post { DAAM_V8.creators[creator] == false : "Illegal Operaion: inviteCreator" }

            DAAM_V8.creators.insert(key: creator, false ) // Creator account is setup but not active untill accepted.

            log("Sent Creator Invitation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)      
        }

        pub fun inviteMinter(_ minter: Address) {   // Admin invites a new Minter (Key)
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status : "You're no longer a have Access."
            }
            post { DAAM_V8.minters[minter] == false : "Illegal Operaion: inviteCreator" }

            DAAM_V8.minters.insert(key: minter, false) // Minter Key is setup but not active untill accepted.
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdmin(admin: Address) { // Two Admin to Remove Admin
            pre  {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status: "You're no longer a have Access."
            }

            let vote = 3 as Int
            DAAM_V8.remove.insert(key: self.grantee, admin) // Append removal list
            if DAAM_V8.remove.length >= vote {                      // If votes is 3 or greater
                var counter: {Address: Int} = {} // {To Remove : Total Votes}
                // Talley Votes
                for a in DAAM_V8.remove.keys {
                    let remove = DAAM_V8.remove[a]! // get To Remove
                    // increment counter
                    if counter[remove] == nil {
                        counter.insert(key: remove, 1 as Int)
                    } else {
                        let value = counter[remove]! + 1 as Int
                        counter.insert(key: remove, value)
                    }
                }
                // Remove all with a vote of 3 or greater
                for c in counter.keys {
                    if counter[c]! >= vote {        // Does To Remove have enough votes to be removed
                        DAAM_V8.remove = {}           // Reset DAAM_V8.Remove
                        DAAM_V8.admins.remove(key: c) // Remove selected Admin
                        log("Removed Admin")
                        emit AdminRemoved(admin: admin)
                    }
                }                
            } // end if
        }

        pub fun removeAgent(agent: Address) { // Admin removes selected Agent by Address
            pre  {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                    : "You're no longer a have Access."
                DAAM_V8.agents.containsKey(agent) : "This is not a Agent Address."
            }
            post { !DAAM_V8.agents.containsKey(agent) : "Illegal operation: removeAgent" } // Unreachable

            DAAM_V8.agents.remove(key: agent)    // Remove Agent from list
            log("Removed Agent")
            emit AgentRemoved(agent: agent)
        }

        pub fun removeCreator(creator: Address) { // Admin removes selected Creator by Address
            pre {  
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                        : "You're no longer a have Access."
                DAAM_V8.creators.containsKey(creator) : "This is not a Creator address."
            }
            post { !DAAM_V8.creators.containsKey(creator) : "Illegal operation: removeCreator" } // Unreachable

            DAAM_V8.creators.remove(key: creator)    // Remove Creator from list
            DAAM_V8.metadataCap.remove(key: creator) // Remove Metadata Capability from list
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        pub fun removeMinter(minter: Address) { // Admin removes selected Agent by Address
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                      : "You're no longer a have Access."
                DAAM_V8.minters.containsKey(minter) : "This is not a Minter Address."
            }
            post { !DAAM_V8.minters.containsKey(minter) : "Illegal operation: removeAgent" } // Unreachable
            DAAM_V8.minters.remove(key: minter)    // Remove Agent from list
            log("Removed Minter")
            emit MinterRemoved(minter: minter)
        }

        // Admin can Change Agent status 
        pub fun changeAgentStatus(agent: Address, status: Bool) {
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                     : "You're no longer a have Access."
                DAAM_V8.agents.containsKey(agent)  : "Wrong Address. This is not an Agent."
                DAAM_V8.agents[agent] != status    : "Agent already has this Status."
            }
            post { DAAM_V8.agents[agent] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM_V8.agents[agent] = status // status changed
            log("Agent Status Changed")
            emit ChangeAgentStatus(agent: agent, status: status)
        }        

        // Admin or Agent can Change Creator status 
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                         : "You're no longer a have Access."
                DAAM_V8.creators.containsKey(creator)  : "Wrong Address. This is not a Creator."
                DAAM_V8.creators[creator] != status    : "Agent already has this Status."
            }
            post { DAAM_V8.creators[creator] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM_V8.creators[creator] = status // status changed
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }

        // Admin can Change Minter status 
        pub fun changeMinterStatus(minter: Address, status: Bool) {
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                       : "You're no longer a have Access."
                DAAM_V8.minters.containsKey(minter)  : "Wrong Address. This is not a Minter."
                DAAM_V8.minters[minter] != status    : "Minter already has this Status."
            }
            post { DAAM_V8.minters[minter] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM_V8.minters[minter] = status // status changed
            log("Minter Status Changed")
            emit ChangeMinterStatus(minter: minter, status: status)
        }

        // Admin or Agent can change a Metadata status.
        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM_V8.copyright.containsKey(mid)      : "This is an Invalid MID"
            }            
            DAAM_V8.metadata[mid] = status // change to a new Metadata status
        }      

        // Admin or Agent can change a MIDs copyright status.
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM_V8.copyright.containsKey(mid)      : "This is an Invalid MID"
            }
            post { DAAM_V8.copyright[mid] == copyright  : "Illegal Operation: changeCopyright" } // Unreachable

            DAAM_V8.copyright[mid] = copyright    // Change to new copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        // Get all MIDs & their Status
        pub fun getMetadataStatus(): {UInt64:Bool} { // { MID : Status}
            pre {
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                          : "You're no longer a have Access."
            }
            return DAAM_V8.metadata
        }        
	}
/************************************************************************/
// The Creator Resource (like Admin/Agent) is a permissions Resource. This allows the Creator
// to Create Metadata which inturn can be made in NFTs after Minting
    pub resource Creator {
        pub var agent: {UInt64: Address} // {MID: Agent Address} // preparation for V2
        access (contract) let grantee: Address

        init(_ creator: Address) {
            self.agent = {}
            self.grantee = creator
        }  // init Creators agent(s)

        // Used to create a Metadata Generator when initalizing Creator Storge
        pub fun newMetadataGenerator(): @MetadataGenerator {
            pre{
                self.grantee == self.owner!.address : "Permission Denied"
                DAAM_V8.creators.containsKey(self.grantee) : "You're not a Creator."
                DAAM_V8.creators[self.grantee] == true     : "This Creators' account is Frozen."
            }
            return <- create MetadataGenerator(self.grantee) // return Metadata Generator
        }

        // Used to create a Request Generator when initalizing Creator Storge
        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                self.grantee == self.owner!.address : "Permission Denied"
                DAAM_V8.creators.containsKey(self.grantee) : "You're not a Creator."
                DAAM_V8.creators[self.grantee] == true     : "This Creators' account is Frozen."
            }
            return <- create RequestGenerator(self.grantee) // return Request Generator
        } 
    }
/************************************************************************/
// mintNFT mints a new NFT and returns it.
// Note: new is defined by newly Minted. Age is not a consideration.
    pub resource Minter
    {
        priv let grantee: Address

        init(_ minter: Address) {
            self.grantee = minter
            DAAM_V8.minters.insert(key: minter, true) // Insert new Minter in minter list.
        }

        pub fun mintNFT(metadata: @Metadata): @DAAM_V8.NFT {
            pre{
                metadata.counter <= metadata.series || metadata.series == 0 : "Internal Error: Mint Counter"
                DAAM_V8.creators.containsKey(metadata.creator) : "You're not a Creator."
                DAAM_V8.creators[metadata.creator] == true     : "This Creators' account is Frozen."
                DAAM_V8.request.containsKey(metadata.mid)      : "Invalid Request"
            }

            let isLast = metadata.counter == metadata.series // Get print count
            let mid = metadata.mid               // Get MID
            let nft <- create NFT(metadata: <- metadata, request: &DAAM_V8.request[mid] as &Request) // Create NFT

            // Update Request, if last remove.
            if isLast {
                let request <- DAAM_V8.request.remove(key: mid)! // Get Request using MID
                destroy request       // if last destroy request, Request not needed. Counter has reached limit.
            } 
            self.newNFT(id: nft.id) // Mark NFT as new
            
            log("Minited NFT: ".concat(nft.id.toString()))
            emit MintedNFT(id: nft.id)

            return <- nft  // return NFT
        }

        pub fun createMinterAccess(): @MinterAccess {
            return <- create MinterAccess(self.grantee)
        }

        // Removes token from 'new' list. 'new' is defines as newly Mited. Age is not a consideration.
        pub fun notNew(tokenID: UInt64) {
            pre  {
                self.grantee == self.owner!.address : "Permission Denied"
                DAAM_V8.newNFTs.contains(tokenID)  : "This NFT is not a new NFT"
            }
            post { !DAAM_V8.newNFTs.contains(tokenID) : "Illegal Operation: notNew" } // Unreachable

            var counter = 0 as UInt64              // start the conter
            for nft in DAAM_V8.newNFTs {              // cycle through 'new' list
                if nft == tokenID {                // if Token ID is found
                    DAAM_V8.newNFTs.remove(at: counter) // remove from 'new' list
                    break
                } else {
                    counter = counter + 1          // increment counter
                }
            } // end for
        }

        // Add NFT to 'new' list
        priv fun newNFT(id: UInt64) {
            pre  { !DAAM_V8.newNFTs.contains(id) : "Token ID is already set to New." }
            post { DAAM_V8.newNFTs.contains(id)  : "Illegal Operation: newNFT" }
                DAAM_V8.newNFTs.append(id)       // Append 'new' list
        }      
    }
/************************************************************************/
pub resource MinterAccess
{
    priv let original_address: Address

    init(_ user: Address) { self.original_address = user }

    pub fun validate(): Bool {
        return DAAM_V8.minters[self.original_address]!
    }
}
/************************************************************************/
    // Public DAAM_V8 functions

    // answerInvitation Functions:
    // True : invitation is accepted and invitation setting reset
    // False: invitation is declined and invitation setting reset

    // The Admin potential can accept (True) or deny (False)
    pub fun answerAdminInvite(newAdmin: AuthAccount, submit: Bool): @Admin? {
        pre {
            DAAM_V8.admins.containsKey(newAdmin.address)    : "You got no DAAM_V8 Admin invite."
            !DAAM_V8.admins[newAdmin.address]!              : "You Admin Access is Frozen."
            !DAAM_V8.agents.containsKey(newAdmin.address)   : "A Admin can not use the same address as an Agent."
            !DAAM_V8.creators.containsKey(newAdmin.address) : "A Admin can not use the same address as an Creator."
            Profile.check(newAdmin.address)  : "You can't be a DAAM_V8 Admin without a Profile first. Go make a Profile first."
        }

        if !submit { 
            DAAM_V8.admins.remove(key: newAdmin.address) // Release Admin
            return nil
        }  // Refused invitation. Return and end function
        
        // Invitation accepted at this point
        DAAM_V8.admins[newAdmin.address] = submit // Insert new Admin in admins list.
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM_V8") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin.address)!      // Accepted and returning Admin Resource
    }

    // // The Agent potential can accept (True) or deny (False)
    pub fun answerAgentInvite(newAgent: AuthAccount, submit: Bool): @Admin{Agent}?
    {
        pre {
            !DAAM_V8.admins.containsKey(newAgent.address)   : "A Agent can not use the same address as an Admin."
            !DAAM_V8.creators.containsKey(newAgent.address) : "A Agent can not use the same address as an Creator."
            DAAM_V8.agents.containsKey(newAgent.address)    : "You got no DAAM_V8 Agent invite."
            !DAAM_V8.agents[newAgent.address]!              : "You Agent Access is Frozen."
            Profile.check(newAgent.address)  : "You can't be a DAAM_V8 Agent without a Profile first. Go make a Profile first."
        }

        if !submit {                                  // Refused invitation. 
            DAAM_V8.agents.remove(key: newAgent.address) // Remove potential from Agent list
            return nil                                // Return and end function
        }
        // Invitation accepted at this point
        DAAM_V8.agents[newAgent.address] = submit        // Add Agent & set Status (True)
        log("Agent: ".concat(newAgent.address.toString()).concat(" added to DAAM_V8") )
        emit NewAgent(agent: newAgent.address)
        return <- create Admin(newAgent.address)!             // Return Admin Resource as {Agent}
    }

    // // The Creator potential can accept (True) or deny (False)
    pub fun answerCreatorInvite(newCreator: AuthAccount, submit: Bool): @Creator? {
        pre {
            !DAAM_V8.admins.containsKey(newCreator.address)  : "A Creator can not use the same address as an Admin."
            !DAAM_V8.agents.containsKey(newCreator.address)  : "A Creator can not use the same address as an Agent."
            DAAM_V8.creators.containsKey(newCreator.address) : "You got no DAAM_V8 Creator invite."
            !DAAM_V8.creators[newCreator.address]!           : "You Creator Access is Frozen."
            Profile.check(newCreator.address)  : "You can't be a DAAM_V8 Creator without a Profile first. Go make a Profile first."
        }

        if !submit {                                       // Refused invitation.
            DAAM_V8.creators.remove(key: newCreator.address)  // Remove potential from Agent list
            return nil                                     // Return and end function
        }
        // Invitation accepted at this point
        DAAM_V8.creators[newCreator.address] = submit         // Add Creator & set Status (True)
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM_V8") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator(newCreator.address)!                         // Return Creator Resource
    }

    pub fun answerMinterInvite(newMinter: AuthAccount, submit: Bool): @Minter? {
        pre {
            DAAM_V8.minters.containsKey(newMinter.address) : "You do not have a Minter Invitation"
            !DAAM_V8.minters[newMinter.address]!           : "You Minter Access is Frozen."
        }

        if !submit {                                      // Refused invitation. 
            DAAM_V8.minters.remove(key: newMinter.address) // Remove potential from Agent list
            return nil                                    // Return and end function
        }
        // Invitation accepted at this point
        log("Minter: ".concat(newMinter.address.toString()) )
        emit NewMinter(minter: newMinter.address)
        return <- create Minter(newMinter.address)             // Return Minter (Key) Resource
    }
    
    // Create an new Collection to store NFTs
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        post { result.getIDs().length == 0: "The created collection must be empty!" }
        return <- create Collection() // Return Collection Resource
    }

    // Create an new Collection to store NFTs
    pub fun createDAAMCollection(): @DAAM_V8.Collection {
        post { result.getIDs().length == 0: "The created DAAM_V8 collection must be empty!" }
        return <- create DAAM_V8.Collection() // Return Collection Resource
    }

    // Return list of Creators
    pub fun getCreators(): [Address] {
        var clist: [Address] = []
        for creator in self.creators.keys {
            clist.append(creator)
        }
        return clist
    }

    // Return Copyright Status. nil = non-existent MID
    pub fun getCopyright(mid: UInt64): CopyrightStatus? { 
        return self.copyright[mid]
    }

    pub fun isNFTNew(id: UInt64): Bool {  // Return True if new
        return self.newNFTs.contains(id)   // Note: 'New' is defined a newly minted. Age is not a consideration. 
    }

    pub fun isAdmin(_ admin: Address): Bool? { // Returns Admin Status
        return self.admins[admin]
    }

    pub fun isAgent(_ agent: Address): Bool? { // Returns Agent status
        return self.agents[agent] // nil = not an agent, false = invited to be am agent, true = is an agent
    }

    pub fun isMinter(_ minter: Address): Bool? { // Returns Agent status
        return self.minters[minter] // nil = not an agent, false = invited to be am agent, true = is an agent
    }

    pub fun isCreator(_ creator: Address): Bool? { // Returns Creator status
        return self.creators[creator] // nil = not a creator, false = invited to be a creator, true = is a creator
    }
/************************************************************************/
// Init DAAM_V8 Contract variables
    
    init(agency: Address, founder: Address)
    {
        // Paths
        self.collectionPublicPath  = /public/DAAM_Collection
        self.collectionStoragePath = /storage/DAAM_Collection
        self.metadataPublicPath    = /public/DAAM_SubmitNFT
        self.metadataStoragePath   = /storage/DAAM_SubmitNFT
        self.adminPrivatePath      = /private/DAAM_Admin
        self.adminStoragePath      = /storage/DAAM_Admin
        self.minterPrivatePath     = /private/DAAM_Minter
        self.minterStoragePath     = /storage/DAAM_Minter
        self.creatorPrivatePath    = /private/DAAM_Creator
        self.creatorStoragePath    = /storage/DAAM_Creator
        self.requestPrivatePath    = /private/DAAM_Request
        self.requestStoragePath    = /storage/DAAM_Request
        // Internal  variables
        self.agency = agency
        // Initialize variables
        self.admins    = {}
        self.remove    = {}
        self.request  <- {}
        self.copyright = {}
        self.agents    = {} 
        self.creators  = {}
        self.minters   = {}
        self.metadata  = {}
        self.metadataCap = {}
        self.newNFTs   = []
        // Counter varibbles
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        self.admins.insert(key: founder, false)

        emit ContractInitialized()
	}
}
