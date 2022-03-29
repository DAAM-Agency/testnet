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
// Agent interface. List of all powers belonging to the Agent
    pub resource interface Agent 
    {
        pub var status: Bool // the current status of the Admin

        pub fun inviteCreator(_ creator: Address)                   // Admin invites a new creator       
        pub fun changeCreatorStatus(creator: Address, status: Bool) // Admin or Agent change Creator status        
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) // Admin or Agenct can change MID copyright status
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

        init(_ admin: AuthAccount) {
            self.status  = true      // Default Admin status: True
            self.grantee = admin.address
        }

        // Used only when genreating a new Admin. Creates a Resource Generator for Negoiations.
        pub fun newRequestGenerator(): @RequestGenerator {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status : "You're no longer a have Access."
            }
            return <- create RequestGenerator(self.grantee) // return new Request
        }

        pub fun inviteAdmin(newAdmin: Address) {     // Admin invite a new Admin
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                    : "You're no longer a have Access."
                DAAM.creators[newAdmin] == nil : "A Admin can not use the same address as an Creator."
                DAAM.agents[newAdmin] == nil   : "A Admin can not use the same address as an Agent."
                DAAM.admins[newAdmin] == nil   : "They're already sa DAAM Admin!!!"
                Profile.check(newAdmin) : "You can't be a DAAM Admin without a Profile! Go make one Fool!!"
            }
            post { DAAM.admins[newAdmin] == false : "Illegal Operaion: inviteAdmin" }

            DAAM.admins.insert(key: newAdmin, false) // Admin account is setup but not active untill accepted.
            log("Sent Admin Invitation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteAgent(_ agent: Address) {    // Admin ivites new Agent
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                 : "You're no longer a have Access."
                DAAM.admins[agent] == nil   : "A Agent can not use the same address as an Admin."
                DAAM.creators[agent] == nil : "A Agent can not use the same address as an Creator."
                DAAM.agents[agent] == nil   : "They're already a DAAM Agent!!!"
                Profile.check(agent) : "You can't be a DAAM Admin without a Profile! Go make one Fool!!"
            }
            post { DAAM.agents[agent] == false : "Illegal Operaion: inviteAdmin" }

            DAAM.agents.insert(key: agent, false ) // Agent account is setup but not active untill accepted.
            log("Sent Agent Invitation: ".concat(agent.toString()) )
            emit AgentInvited(agent: agent)         
        }

        pub fun inviteCreator(_ creator: Address) {    // Admin or Agent invite a new creator
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                   : "You're no longer a have Access."
                DAAM.admins[creator]   == nil : "A Creator can not use the same address as an Admin."
                DAAM.agents[creator]   == nil : "A Creator can not use the same address as an Agent."
                DAAM.creators[creator] == nil : "They're already a DAAM Creator!!!"
                Profile.check(creator) : "You can't be a DAAM Creator without a Profile! Go make one Fool!!"
            }
            post { DAAM.creators[creator] == false : "Illegal Operaion: inviteCreator" }

            DAAM.creators.insert(key: creator, false ) // Creator account is setup but not active untill accepted.

            log("Sent Creator Invitation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)      
        }

        pub fun inviteMinter(_ minter: Address) {   // Admin invites a new Minter (Key)
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status : "You're no longer a have Access."
            }
            post { DAAM.minters[minter] == false : "Illegal Operaion: inviteCreator" }

            DAAM.minters.insert(key: minter, false) // Minter Key is setup but not active untill accepted.
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdmin(admin: Address) { // Two Admin to Remove Admin
            pre  {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status: "You're no longer a have Access."
            }

            let vote = 2 as Int // TODO change to 3
            DAAM.remove.insert(key: self.owner?.address!, admin) // Append removal list
            if DAAM.remove.length >= vote {                      // If votes is 3 or greater
                var counter: {Address: Int} = {} // {To Remove : Total Votes}
                // Talley Votes
                for a in DAAM.remove.keys {
                    let remove = DAAM.remove[a]! // get To Remove
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
                        DAAM.remove = {}           // Reset DAAM.Remove
                        DAAM.admins.remove(key: c) // Remove selected Admin
                        log("Removed Admin")
                        emit AdminRemoved(admin: admin)
                    }
                }                
            } // end if
        }

        pub fun removeAgent(agent: Address) { // Admin removes selected Agent by Address
            pre  {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                    : "You're no longer a have Access."
                DAAM.agents.containsKey(agent) : "This is not a Agent Address."
            }
            post { !DAAM.agents.containsKey(agent) : "Illegal operation: removeAgent" } // Unreachable

            DAAM.agents.remove(key: agent)    // Remove Agent from list
            log("Removed Agent")
            emit AgentRemoved(agent: agent)
        }

        pub fun removeCreator(creator: Address) { // Admin removes selected Creator by Address
            pre {  
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                        : "You're no longer a have Access."
                DAAM.creators.containsKey(creator) : "This is not a Creator address."
            }
            post { !DAAM.creators.containsKey(creator) : "Illegal operation: removeCreator" } // Unreachable

            DAAM.creators.remove(key: creator)    // Remove Creator from list
            DAAM.metadataCap.remove(key: creator) // Remove Metadata Capability from list
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        pub fun removeMinter(minter: Address) { // Admin removes selected Agent by Address
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                      : "You're no longer a have Access."
                DAAM.minters.containsKey(minter) : "This is not a Minter Address."
            }
            post { !DAAM.minters.containsKey(minter) : "Illegal operation: removeAgent" } // Unreachable
            DAAM.minters.remove(key: minter)    // Remove Agent from list
            log("Removed Minter")
            emit MinterRemoved(minter: minter)
        }

        // Admin can Change Agent status 
        pub fun changeAgentStatus(agent: Address, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                     : "You're no longer a have Access."
                DAAM.agents.containsKey(agent)  : "Wrong Address. This is not an Agent."
                DAAM.agents[agent] != status    : "Agent already has this Status."
            }
            post { DAAM.agents[agent] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM.agents[agent] = status // status changed
            log("Agent Status Changed")
            emit ChangeAgentStatus(agent: agent, status: status)
        }        

        // Admin or Agent can Change Creator status 
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                         : "You're no longer a have Access."
                DAAM.creators.containsKey(creator)  : "Wrong Address. This is not a Creator."
                DAAM.creators[creator] != status    : "Agent already has this Status."
            }
            post { DAAM.creators[creator] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM.creators[creator] = status // status changed
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }

        // Admin can Change Minter status 
        pub fun changeMinterStatus(minter: Address, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                       : "You're no longer a have Access."
                DAAM.minters.containsKey(minter)  : "Wrong Address. This is not a Minter."
                DAAM.minters[minter] != status    : "Minter already has this Status."
            }
            post { DAAM.minters[minter] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM.minters[minter] = status // status changed
            log("Minter Status Changed")
            emit ChangeMinterStatus(minter: minter, status: status)
        }         

        // Admin or Agent can change a MIDs copyright status.
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM.copyright.containsKey(mid)      : "This is an Invalid MID"
            }
            post { DAAM.copyright[mid] == copyright  : "Illegal Operation: changeCopyright" } // Unreachable

            DAAM.copyright[mid] = copyright    // Change to new copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        // Get all MIDs & their Status
        pub fun getMetadataStatus(): {UInt64:Bool} { // { MID : Status}
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
            }
            return DAAM.metadata
        }
        // Mainly for testing, Considering Removing TODO
        pub fun getMetadatasRef(creator: Address): {UInt64 : Metadata} {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM.creators[creator] != nil        : "You have not selected a Creator."
            }
            let mCap = DAAM.metadataCap[creator]!.borrow()! as &MetadataGenerator{MetadataGeneratorPublic}
            return mCap.getMetadata()
        }
        // Mainly for testing, Considering Removing TODO
        pub fun getMetadataRef(creator: Address, mid: UInt64): Metadata {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM.creators[creator] != nil        : "You have not selected a Creator."
                DAAM.metadata.containsKey(mid)       : "Incorrect MID"
            }
            let mCap = DAAM.metadataCap[creator]!.borrow()! as &MetadataGenerator{MetadataGeneratorPublic}
            return mCap.getMetadata()[mid]!
        }

        // Admin or Agent can change a Metadata status.
        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM.copyright.containsKey(mid)      : "This is an Invalid MID"
            }            
            DAAM.metadata[mid] = status // change to a new Metadata status
        }
	}
/************************************************************************/
// The Creator Resource (like Admin/Agent) is a permissions Resource. This allows the Creator
// to Create Metadata which inturn can be made in NFTs after Minting
    pub resource Creator {
        pub var agent: {UInt64: Address} // {MID: Agent Address} // preparation for V2
        priv let grantee: Address

        init(_ creator: AuthAccount) {
            self.agent = {}
            self.grantee = creator.address
        }  // init Creators agent(s)

        // Used to create a Metadata Generator when initalizing Creator Storge
        pub fun newMetadataGenerator(): @MetadataGenerator {
            pre{
                self.grantee == self.owner?.address! : "Permission Denied"
                DAAM.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create MetadataGenerator(self.grantee) // return Metadata Generator
        }

        // Used to create a Request Generator when initalizing Creator Storge
        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                self.grantee == self.owner?.address! : "Permission Denied"
                DAAM.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
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
        init(_ minter: AuthAccount) {
            self.grantee = minter.address
            DAAM.minters.insert(key: minter.address, true) // Insert new Minter in minter list.
        }

        pub fun mintNFT(metadata: @MetadataHolder): @DAAM.NFT {
            pre{
                self.grantee == self.owner?.address! : "Permission Denied"
                metadata.metadata.counter <= metadata.metadata.series || metadata.metadata.series == 0 : "Internal Error: Mint Counter"
                DAAM.creators.containsKey(metadata.metadata.creator) : "You're not a Creator."
                DAAM.creators[metadata.metadata.creator] == true     : "This Creators' account is Frozen."
                DAAM.request.containsKey(metadata.metadata.mid)      : "Invalid Request"
            }
            let isLast = metadata.metadata.counter == metadata.metadata.series // Get print count
            let mid = metadata.metadata.mid               // Get MID
            let nft <- create NFT(metadata: <- metadata, request: &DAAM.request[mid] as &Request) // Create NFT

            // Update Request, if last remove.
            if isLast {
                let request <- DAAM.request.remove(key: mid)! // Get Request using MID
                destroy request       // if last destroy request, Request not needed. Counter has reached limit.
            } 
            self.newNFT(id: nft.id) // Mark NFT as new
            
            log("Minited NFT: ".concat(nft.id.toString()))
            emit MintedNFT(id: nft.id)

            return <- nft  // return NFT
        }

        // Removes token from 'new' list. 'new' is defines as newly Mited. Age is not a consideration.
        pub fun notNew(tokenID: UInt64) {
            pre  {
                self.grantee == self.owner?.address! : "Permission Denied"
                DAAM.newNFTs.contains(tokenID)  : "This NFT is not a new NFT"
            }
            post { !DAAM.newNFTs.contains(tokenID) : "Illegal Operation: notNew" } // Unreachable

            var counter = 0 as UInt64              // start the conter
            for nft in DAAM.newNFTs {              // cycle through 'new' list
                if nft == tokenID {                // if Token ID is found
                    DAAM.newNFTs.remove(at: counter) // remove from 'new' list
                    break
                } else {
                    counter = counter + 1          // increment counter
                }
            } // end for
        }

        // Add NFT to 'new' list
        priv fun newNFT(id: UInt64) {
            pre  { !DAAM.newNFTs.contains(id) : "Token ID is already set to New." }
            post { DAAM.newNFTs.contains(id)  : "Illegal Operation: newNFT" }
                DAAM.newNFTs.append(id)       // Append 'new' list
        }        
    }
/************************************************************************/
    // Public DAAM functions

    // answerInvitation Functions:
    // True : invitation is accepted and invitation setting reset
    // False: invitation is declined and invitation setting reset

    // The Admin potential can accept (True) or deny (False)
    pub fun answerAdminInvite(newAdmin: AuthAccount, submit: Bool): @Admin? {
        pre {
            newAdmin.borrow<&DAAM.Admin{DAAM.Agent}>(from: self.adminStoragePath) == nil : "You are aleady an Admin."
            DAAM.admins.containsKey(newAdmin.address)    : "You got no DAAM Admin invite."
            !DAAM.agents.containsKey(newAdmin.address)   : "A Admin can not use the same address as an Agent."
            !DAAM.creators.containsKey(newAdmin.address) : "A Admin can not use the same address as an Creator."
            Profile.check(newAdmin.address)  : "You can't be a DAAM Admin without a Profile first. Go make a Profile first."
        }

        if !submit { 
            DAAM.admins.remove(key: newAdmin.address) // Release Admin
            return nil
        }  // Refused invitation. Return and end function
        
        // Invitation accepted at this point
        DAAM.admins[newAdmin.address] = submit // Insert new Admin in admins list.
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin)!      // Accepted and returning Admin Resource
    }

    // // The Agent potential can accept (True) or deny (False)
    pub fun answerAgentInvite(newAgent: AuthAccount, submit: Bool): @Admin{Agent}?
    {
        pre {
            newAgent.borrow<&DAAM.Admin{DAAM.Agent}>(from: self.adminStoragePath) == nil : "You are aleady an Agent."
            !DAAM.admins.containsKey(newAgent.address)   : "A Agent can not use the same address as an Admin."
            !DAAM.creators.containsKey(newAgent.address) : "A Agent can not use the same address as an Creator."
            DAAM.agents.containsKey(newAgent.address)    : "You got no DAAM Agent invite."
            Profile.check(newAgent.address)  : "You can't be a DAAM Agent without a Profile first. Go make a Profile first."
        }

        if !submit {                                  // Refused invitation. 
            DAAM.agents.remove(key: newAgent.address) // Remove potential from Agent list
            return nil                                // Return and end function
        }
        // Invitation accepted at this point
        DAAM.agents[newAgent.address] = submit        // Add Agent & set Status (True)
        log("Agent: ".concat(newAgent.address.toString()).concat(" added to DAAM") )
        emit NewAgent(agent: newAgent.address)
        return <- create Admin(newAgent)!             // Return Admin Resource as {Agent}
    }

    // // The Creator potential can accept (True) or deny (False)
    pub fun answerCreatorInvite(newCreator: AuthAccount, submit: Bool): @Creator? {
        pre {
            newCreator.borrow<&DAAM.Creator>(from: self.creatorStoragePath) == nil : "You are aleady a Creator."
            !DAAM.admins.containsKey(newCreator.address)  : "A Creator can not use the same address as an Admin."
            !DAAM.agents.containsKey(newCreator.address)    : "A Creator can not use the same address as an Agent."
            DAAM.creators.containsKey(newCreator.address) : "You got no DAAM Creator invite."
            Profile.check(newCreator.address)  : "You can't be a DAAM Creator without a Profile first. Go make a Profile first."
        }

        if !submit {                                       // Refused invitation.
            DAAM.creators.remove(key: newCreator.address)  // Remove potential from Agent list
            return nil                                     // Return and end function
        }
        // Invitation accepted at this point
        DAAM.creators[newCreator.address] = submit         // Add Creator & set Status (True)
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator(newCreator)!                         // Return Creator Resource
    }

    pub fun answerMinterInvite(minter: AuthAccount, submit: Bool): @Minter? {
        pre {
            minter.borrow<&DAAM.Minter>(from: self.minterStoragePath) == nil : "You are aleady a Minter."
            DAAM.minters.containsKey(minter.address) : "You do not have a Minter Invitation"
        }

        if !submit {                                 // Refused invitation. 
            DAAM.minters.remove(key: minter.address) // Remove potential from Agent list
            return nil                               // Return and end function
        }
        // Invitation accepted at this point
        log("Minter: ".concat(minter.address.toString()) )
        emit NewMinter(minter: minter.address)
        return <- create Minter(minter)             // Return Minter (Key) Resource
    }
    
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
	// TESTNET ONLY FUNCTION !!!! // TODO REMOVE

    pub fun resetAdmin(_ admin: Address) {
        self.admins.insert(key: admin, false)
    }

    // END TESNET FUNCTIONS
/************************************************************************/
// Init DAAM Contract variables
    
    init(agency: Address, founder: Address)
    {
        // Paths
        self.collectionPublicPath  = /public/DAAM_Collection
        self.collectionStoragePath = /storage/DAAM_Collection
        self.metadataPrivatePath   = /public/DAAM_SubmitNFT
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
