// daam_nft.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import FungibleToken    from 0xee82856bf20e2aa6 
import Profile          from 0x192440c99cb17282
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
    pub event NewCreator(creator: Address)       // A new Creator has been addeed. Accepted Invite
    pub event AdminInvited(admin  : Address)     // Admin has been invited
    pub event AgentInvited(agent  : Address)     // Agent has been invited
    pub event CreatorInvited(creator: Address)   // Creator has been invited
    pub event MinterSetup(minter: Address)       // Minter has been invited
    pub event AddMetadata()                      // Metadata Added
    pub event MintedNFT(id: UInt64)              // Minted NFT
    pub event ChangedCopyright(metadataID: UInt64) // Copyright has been changed to a MID 
    pub event ChangeCreatorStatus(creator: Address, status: Bool) // Creator Status has been changed by Admin
    pub event AdminRemoved(admin: Address)       // Admin has been removed
    pub event AgentRemoved(agent: Address)       // Agent has been removed by Admin
    pub event CreatorRemoved(creator: Address)   // Creator has been removed by Admin
    pub event RequestAccepted(mid: UInt64)       // Royality rate has been accepted 
    pub event RemovedMetadata(mid: UInt64)       // Metadata has been removed by Creator
    pub event RemovedAdminInvite()               // Admin invitation has been recinded
    // Paths
    pub let collectionPublicPath  : PublicPath   // Public path to Collection
    pub let collectionStoragePath : StoragePath  // Storage path to Collection
    pub let metadataPublicPath    : PublicPath   // Public path to Metadata Generator
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
    pub var totalSupply: UInt64                     // the total supply of NFTs, also used as counter for token ID
    access(contract) var adminPending : Address?    // Only 1 admin can be invited at a time
    access(contract) var minterPending: Address?    // Only 1 Minter can be invited at a time & there should only be one.
    access(contract) var admins  : {Address: Bool}  // {Admin Address : status}   Admin address are stored here
    access(contract) var agents  : {Address: Bool}  // {Agents Address : status}   Agents address are stored here // preparation for V2
    access(contract) var creators: {Address: Bool}  // {Creator Address : status} Creator address are stored here
    access(contract) var creatorCap: {Address: Capability<&DAAM.MetadataGenerator> } // {Address : Capability of Metadata}
    access(contract) var metadata: {UInt64: Bool}   // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var request : @{UInt64: Request}  // {MID : @Request } Request are stored here by MID
    access(contract) var copyright: {UInt64: CopyrightStatus}       // {NFT.id : CopyrightStatus} Get Copyright Status by Token ID
    // Variables 
    access(contract) var metadataCounterID : UInt64   // The Metadta ID counter for MetadataID.
    access(contract) var newNFTs: [UInt64]    // A list of newly minted NFTs. 'New' is defined as 'never sold'. Age is Not a consideration.
    pub let agency : Address     // DAAM Ageny Address
/***********************************************************************/
// Copyright enumeration status
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
            pub case INCLUDED
}
/***********************************************************************/
// Used to make requests for royality. A resource for Neogoation of royalities.
// When both parties agree on 'royality' the Request is considered valid aka isValid() = true and
// Neogoation may not continue. V2 Featur TODO
// Request manage the royality rate
// Accept Default are auto agreements
pub resource Request {
    access(contract) let mid       : UInt64                // Metadata ID number is stored
    access(contract) var royality  : {Address : UFix64}    // current royality neogoation.
    access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(metadata: &Metadata) {
        self.mid       = metadata.mid    // Get Metadata ID
        DAAM.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
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
    init() {}
    // Accept the default Request. No Neogoation is required.
    // Percentages are between 10% - 30%
    pub fun acceptDefault(creator: AuthAccount, metadata: &Metadata, percentage: UFix64) {
        pre { percentage >= 0.1 && percentage <= 0.3 : "Percentage must be inbetween 10% to 30%." }

        let mid = metadata.mid                             // get MID
        var royality = {DAAM.agency: (0.1 * percentage) }  // get Agency percentage, Agency takes 10% of Creator
        royality.insert(key: self.owner?.address!, (0.9 * percentage) ) // get Creator percentage

        let request <-! create Request(metadata: metadata) // get request
        request.acceptDefault(royality: royality)          // append royality rate

        let old <- DAAM.request.insert(key: mid, <-request) // advice DAAM of request
        destroy old // destroy place holder
        
        log("Request Accepted, MID: ".concat(mid.toString()) )
        emit RequestAccepted(mid: mid)
    }
    // Get the Request resource, exclusive for Minting
    pub fun getRequest(metadata: &MetadataHolder): @Request {
        pre {
            metadata != nil                                  : "Metadata Holder is Empty."
            DAAM.request.containsKey(metadata.getMID() )     : "No Request made."
            DAAM.getRequestValidity(mid: metadata.getMID() ) : "This request has not been approved."
        }
        let request <- DAAM.request.remove(key: metadata.metadata.mid)! // Remove Request
        return <- request // Return requested Request
    }
}
/************************************************************************/
    pub struct Metadata {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let mid       : UInt64   // Metadata ID number
        pub let creator   : Address  // Creator of NFT
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let data      : String   // JSON see metadata.json all data ABOUT the NFT is stored here
        pub let thumbnail : String   // JSON see metadata.json all thumbnails are stored here
        pub let file      : String   // JSON see metadata.json all NFT file formats are stored here
        
        init(creator: Address, series: UInt64, data: String, thumbnail: String, file: String, counter: UInt64) {
            pre {
                counter != 0 as UInt64 : "Illegal operation. Internal Error: Metadata" // Unreachabe
                (series != 0 && counter <= series) || series == 0 : "Reached limit on prints."
            }
            // Init all NFT setting
            self.mid       = DAAM.metadataCounterID // init MID with counter
            self.creator   = creator   // creator of NFT
            self.series    = series    // total prints
            self.counter   = counter   // current print of total prints
            self.data      = data      // data,about,misc page
            self.thumbnail = thumbnail // thumbnail are stored here
            self.file      = file      // NFT data is stored here
        }
    }
/************************************************************************/
pub resource interface MetadataGeneratorPublic {
    pub fun getMetadatas()     : {UInt64:Metadata}                  // Return Creators' Metadata collection
    pub fun getMetadataRef(mid : UInt64): &Metadata                 // Return specific Metadata of Creator
}
/************************************************************************/
// Verifies each Metadata gets a Metadata ID, and stores the Creators' Metadatas'.
pub resource MetadataGenerator: MetadataGeneratorPublic { 
        // Variables
        access(contract) var metadata : {UInt64 : Metadata} // {mid : metadata}

        init() {
            self.metadata = {}  // Init metadata
        } 

        // addMetadata: Used to add a new Metadata. This sets up the Metadata to be approved by the Admin
        pub fun addMetadata(series: UInt64, data: String, thumbnail: String, file: String) {
            pre{
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
            }
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64  // Must be first, increment Metadata Countert
            let creator = self.owner?.address!               // get Creator
            let metadata = Metadata(creator: creator, series: series, data: data, thumbnail: thumbnail,
                file: file, counter: 1 as UInt64)            // Create Metadata
            self.metadata.insert(key:metadata.mid, metadata) // Save Metadata
            DAAM.metadata.insert(key: metadata.mid, false)   // a metadata ID for Admin approval, currently unapproved (false)
            DAAM.copyright.insert(key:metadata.mid, CopyrightStatus.UNVERIFIED) // default copyright setting

            log("Metadata Generatated ID: ".concat(metadata.mid.toString()) )
            emit AddMetadata()
        }

        // RemoveMetadata uses deleteMetadata to delete the Metadata.
        // But when deleting a submission the request must also be deleted.
        pub fun removeMetadata(mid: UInt64) {
            pre {
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
            }
            self.deleteMetadata(mid: mid)  // Delete Metadata
            let old_request <- DAAM.request.remove(key: mid)  // Get Request
            destroy old_request // Delete Request
        }

        // Used to remove Metadata from the Creators metadata dictionary list.
        priv fun deleteMetadata(mid: UInt64) {
            pre {
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
            }
            self.metadata.remove(key: mid) // Metadata removed. Metadata Template has reached its max count (series)
            DAAM.copyright.remove(key:mid) // remove metadata copyright            
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)
        }
        // Remove Metadata as Resource MetadataHolder. MetadataHolder + Request = NFT.
        // The MetadataHolder will be destroyed along with a matching Request (same MID) in order to create the NFT
        pub fun generateMetadata(mid: UInt64): @MetadataHolder {
            pre {
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
                DAAM.metadata[mid] != nil : "This already has been published."
                DAAM.metadata[mid]!       : "Your Submission was Rejected."
            }            
                        
            let mh <- create MetadataHolder(metadata: self.metadata[mid]!) // Create Current Metadata
            // Verify Metadata Counter (print) is last, if so delete Metadata
            if self.metadata[mid]!.counter == self.metadata[mid]?.series! && self.metadata[mid]?.series! != 0 as UInt64 {
                self.deleteMetadata(mid: mid) // remove metadata template
            } else { // if not last print
                let counter = self.metadata[mid]!.counter + 1 as UInt64 // increment counter
                let new_metadata = Metadata(                            // prep Next Metadata
                    creator: self.metadata[mid]?.creator!, series: self.metadata[mid]?.series!, data: self.metadata[mid]?.data!,
                    thumbnail: self.metadata[mid]?.thumbnail!, file: self.metadata[mid]?.file!, counter: self.metadata[mid]!.counter
                ) 
                self.metadata[mid] = new_metadata // update to new incremented (counter) Metadata
            }
            return <- mh // return Current Metadata  
        }

        // Script function
        pub fun getMetadatas(): {UInt64:Metadata} {  // Return Creators' Metadata collection
            return self.metadata
        }

        pub fun getMetadataRef(mid: UInt64): &Metadata { // Return specific Metadata of Creator
            pre { 
                self.metadata[mid] != nil : "This MID does not exist in your Metadata Collection."
            }
            return &self.metadata[mid]! as &Metadata   // Return Metadata
        }
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
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64 // Increment total supply
            self.id = DAAM.totalSupply                        // Set Token ID with total supply
            self.royality = request.royality                  // Save Request which are the royalities.  
            self.metadata = metadata.metadata                 // Save Metadata from Metadata Holder
            destroy metadata                                  // Destroy no loner needed container Metadata Holder
        }

        pub fun getCopyright(): CopyrightStatus { // Get current NFT Copyright status
            return DAAM.copyright[self.id]! // return copyright status
        }
    }
/************************************************************************/
// Wallet Public standards. For Public access only
pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT) // used to deposit NFT
    pub fun getIDs(): [UInt64]                    // get NFT Token IDs
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT // get NFT as NonFungibleToken.NFT
    pub fun borrowDAAM(id: UInt64): &DAAM.NFT            // get NFT as DAAM.NFT
}     
/************************************************************************/
// Standand Flow Collection Wallet
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens. NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}  // Store NFTs via Token ID
                        
        init() { self.ownedNFTs <- {} } // List of owned NFTs

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
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
        // borrowDAAM gets a reference to an DAAM.NFT in the collection.
        pub fun borrowDAAM(id: UInt64): &DAAM.NFT {
            pre { self.ownedNFTs[id] != nil : "Your Collection is empty." }
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT // Get reference to NFT
            return ref as! &DAAM.NFT                                    // return NFT Reference
        }        

        destroy() { destroy self.ownedNFTs } // Destructor
    }
/************************************************************************/
// Agent interface. List of all powers belonging to the Agent
    pub resource interface Agent 
    {
        pub var status: Bool // the current status of the Admin

        pub fun inviteCreator(_ creator: Address) {  // Admin invites a new creator
            pre {
                self.status                   : "You're no longer a have Access."
                DAAM.admins[creator]   == nil : "A Creator can not use the same address as an Admin."
                DAAM.agents[creator]   == nil : "A Creator can not use the same address as an Agent."
                DAAM.creators[creator] == nil : "They're already a DAAM Creator!!!"
                Profile.check(creator) : "You can't be a DAAM Creator without a Profile! Go make one Fool!!"
            }
            post { DAAM.creators[creator] == false : "Illegal Operaion: inviteCreator" }
        }

        // Admin or Agent change Creator status
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                self.status                         : "You're no longer a have Access."
                DAAM.creators.containsKey(creator)  : "Wrong Address. This is not a Creator."
                DAAM.creators[creator] != status    : "Creator already has this Status."
            }
            post { DAAM.creators[creator] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable
        }
        
        pub fun removeCreator(creator: Address) {      // Admin or Agent can remove Creator
            pre  {
                self.status                        : "You're no longer a have Access."
                DAAM.creators.containsKey(creator) : "This is not a Creator address."
            }
            post { !DAAM.creators.containsKey(creator) : "Illegal operation: removeCreator" } // Unreachabel
        }        

        // Admin or Agent can change Copyright Status of MID
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre  {
                self.status                 : "You're no longer a have Access."
                DAAM.copyright.containsKey(mid)  : "This is an Invalid MID"
            }
            post { DAAM.copyright[mid] == copyright : "Illegal Operation: changeCopyright" } // Unreachable
        }

        // Admin or Agent can change Metadata Status
        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre  {
                self.status                 : "You're no longer a have Access."
                DAAM.copyright.containsKey(mid): "This is an Invalid MID"
            }
        }

        pub fun newRequestGenerator(): @RequestGenerator { // Create Request Generator
            pre { self.status : "You're no longer a have Access." }
        }
    }
/************************************************************************/
// The Admin Resource deletgates permissions between Founders and Agents
pub resource Admin: Agent
{
        pub var status: Bool       // The current status of the Admin
        priv var remove: [Address] // Requires 2 Admins to remove an Admin, the Admins are stored here.

        init(_ admin: AuthAccount) {
            self.status = true      // Default Admin status: True
            self.remove = []        // No removal requests.
            DAAM.admins.insert(key: admin.address, true) // Insert new Admin in admins list.
        }

        // Used only when genreating a new Admin. Creates a Resource Generator for Negoiations.
        pub fun newRequestGenerator(): @RequestGenerator {
            return <- create RequestGenerator() // return new Request
        }

        pub fun inviteAdmin(newAdmin: Address) { // Admin invite a new Admin
            DAAM.adminPending = newAdmin  // Admin is now pending for approval
            log("Sent Admin Invation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteAgent(_ agent: Address) {  // Admin ivites new Agent
            DAAM.agents.insert(key: agent, false ) // Agent account is setup but not active untill accepted.
            log("Sent Agent Invation: ".concat(agent.toString()) )
            emit AgentInvited(agent: agent)         
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin or Agent invite a new creator
            DAAM.creators.insert(key: creator, false ) // Creator account is setup but not active untill accepted.
            log("Sent Creator Invation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)      
        }

        pub fun inviteMinter(_ minter: Address) {  // Admin invites a new Minter (Key)
            DAAM.minterPending = minter // Minter Key is setup but not active untill accepted.
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdminInvite() { // Remove Admin invitation
            DAAM.adminPending = nil  // Clear Admin for pending
            log("Admin Invation Removed")
            emit RemovedAdminInvite()                      
        }

        // Admin or Agent van Change Creator status 
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            DAAM.creators[creator] = status // status changed
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }        

        pub fun removeAdmin(admin: Address) { // Two Admin to Remove Admin
            pre{
                !self.remove.contains(admin) : "You already requested a removal."
            }
            self.remove.append(admin) // Append removal list
            if self.remove.length >= 2 {
                //self.status = false
                DAAM.admins.remove(key: admin) // Remove selected Admin
                log("Removed Admin")
                emit AdminRemoved(admin: admin)
            }
        }

        pub fun removeAgent(agent: Address) { // Admin removes selected Agent by Address
            DAAM.agents.remove(key: agent)    // Remove Agent from list
            log("Removed Agent")
            emit AgentRemoved(agent: agent)
        }

        pub fun removeCreator(creator: Address) { // Admin removes selected Creator by Address
            DAAM.creators.remove(key: creator)    // Remove Creator from list
            DAAM.creatorCap.remove(key: creator)  // Remove Creator Capability
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        // Admin or Agent can change a MIDs copyright status.
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            DAAM.copyright[mid] = copyright    // Change to new copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        // Admin or Agent can change a Metadata status.
        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            DAAM.metadata[mid] = status // change to a new Metadata status
        }
	}
/************************************************************************/
// The Creator Resource (like Admin/Agent) is a permissions Resource. This allows the Creator
// to Create Metadata which inturn can be made in NFTs after Minting
    pub resource Creator {
        pub var agent: {UInt64: Address} // {MID: Agent Address} // preparation for V2

        init() { self.agent = {} }  // init Creators agent(s)

        // Used to create a Metadata Generator when initalizing Creator Storge
        pub fun newMetadataGenerator(): @MetadataGenerator {
            pre{
                DAAM.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create MetadataGenerator() // return Metadata Generator
        }

        // Used to create a Request Generator when initalizing Creator Storge
        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                DAAM.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create RequestGenerator() // return Request Generator
        } 
    }
/************************************************************************/
    pub resource Minter {
        // mintNFT mints a new NFT and returns it.
        // Note: new is defined by newly Minted. Age is not a consideration.
        pub fun mintNFT(metadata: @MetadataHolder): @DAAM.NFT {
            pre{
                DAAM.creators.containsKey(metadata.metadata.creator) : "You're not a Creator."
                DAAM.creators[metadata.metadata.creator] == true     : "This Creators' account is Frozen."
                DAAM.request.containsKey(metadata.metadata.mid)      : "Invalid Request"
                DAAM.getRequestValidity(mid: metadata.metadata.mid)  : "There is no Request for this MID."
            }
            let isLast = metadata.metadata.counter == metadata.metadata.series // Get print count
            let mid = metadata.metadata.mid               // Get MID
            let request <- DAAM.request.remove(key: mid)! // Get Request using MID
            let requestRef = &request as & Request        // Reference the Request
            let nft <- create NFT(metadata: <- metadata, request: requestRef) // Create NFT

            // Update Request, if last remove.
            if isLast {
                destroy request       // if last destroy request, Request not needed. Counter has reached limit.
            } else {             
                let empty_request <- DAAM.request.insert(key: mid, <- request) // re-insert request
                destroy empty_request // destroy place holder
            }

            self.newNFT(id: nft.id) // Mark NFT as new
            
            log("Minited NFT: ".concat(nft.id.toString()))
            emit MintedNFT(id: nft.id)

            return <- nft  // return NFT
        }

        // Removes token from 'new' list. 'new' is defines as newly Mited. Age is not a consideration.
        pub fun notNew(tokenID: UInt64) {
            pre  { DAAM.newNFTs.contains(tokenID)  : "This NFT is not a new NFT" }
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
            DAAM.creators[newAdmin.address] == nil : "An admin can not use the same address as an Creator."
            DAAM.agents[newAdmin.address] == nil   : "An admin can not use the same address as an Agent."
            DAAM.adminPending == newAdmin.address  : "You got no DAAM Admin invite."
            Profile.check(newAdmin.address)        : "You can't be a DAAM Admin without a Profile first. Go make a Profile first."
        }
        DAAM.adminPending = nil    // Release Admin pending (nil)
        if !submit { return nil }  // Refused invation. Return and end function
        // Invitation accepted at this point
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin)! // Accepted and returning Admin Resource
    }

    // // The Agent potential can accept (True) or deny (False)
    pub fun answerAgentInvite(newAgent: AuthAccount, submit: Bool): @Admin{Agent}?
    {
        pre {
            !DAAM.admins.containsKey(newAgent.address)   : "A Agent can not use the same address as an Admin."
            !DAAM.creators.containsKey(newAgent.address) : "A Agent can not use the same address as an Creator."
            DAAM.agents.containsKey(newAgent.address)    : "You got no DAAM Agent invite."
            Profile.check(newAgent.address)  : "You can't be a DAAM Agent without a Profile first. Go make a Profile first."
        }

        if !submit {                                  // Refused invation. 
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
            !DAAM.admins.containsKey(newCreator.address)  : "A Creator can not use the same address as an Admin."
            !DAAM.agents.containsKey(newCreator.address)    : "A Creator can not use the same address as an Agent."
            DAAM.creators.containsKey(newCreator.address) : "You got no DAAM Creator invite."
            Profile.check(newCreator.address)  : "You can't be a DAAM Creator without a Profile first. Go make a Profile first."
        }

        if !submit {                                       // Refused invation.
            DAAM.creators.remove(key: newCreator.address)  // Remove potential from Agent list
            return nil                                     // Return and end function
        }
        // Invitation accepted at this point
        DAAM.creators[newCreator.address] = submit         // Add Creator & set Status (True) 
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator()!                        // Return Creator Resource
    }

    pub fun answerMinterInvite(minter: AuthAccount, submit: Bool): @Minter? {
        pre { DAAM.minterPending == minter.address : "You do not have a Minter Invitation" }
        DAAM.minterPending = nil
        if !submit { return nil }                  // Refused invation. Return and end function
        // Invitation accepted at this point
        log("Minter: ".concat(minter.address.toString()) )
        emit NewMinter(minter: minter.address)
        return <- create Minter()!                 // Return Minter (Key) Resource
    }
    
    // Create an new Collection to store NFTs
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        post { result.getIDs().length == 0: "The created collection must be empty!" }
        return <- create Collection() // Return Collection Resource
    }

    // Verifies if Request is valid
    pub fun getRequestValidity(mid: UInt64): Bool {
        pre { self.request.containsKey(mid) : "The is not a valid MID." }
        return self.request[mid]?.isValid() == true ? true : false // Return validity of Request
    }

    pub fun getCreators(): [Address] {
        var clist: [Address] = []
        for creator in self.creators.keys {
            clist.append(creator)
        }
        return clist
    }

    pub fun getCopyright(mid: UInt64): CopyrightStatus? { // Return Copyright Status. nil = non-existent MID
        return self.copyright[mid]
    }

    pub fun isNFTNew(id: UInt64): Bool {  // Return True if new
        return self.newNFTs.contains(id)   // Note: 'New' is defined a newly minted. Age is not a consideration. 
    }

    pub fun isAdmin(_ admin: Address): Bool { // Returns Admin Status
        return self.admins.containsKey(admin)
    }

    pub fun isAgent(_ agent: Address): Bool? { // Returns Agent status
        return self.agents[agent] // nil = not an agent, false = invited to be am agent, true = is an agent
    }

    pub fun isCreator(_ creator: Address): Bool? { // Returns Creator status
        return self.creators[creator] // nil = not a creator, false = invited to be a creator, true = is a creator
    }

/************************************************************************/
	// TESTNET ONLY FUNCTIONS !!!! // TODO REMOVE

    pub fun resetAdmin(_ admin: Address) {
        self.adminPending = admin
    }

    // END TESNET FUNCTIONS
/************************************************************************/
// Init DAAM Contract variables
    
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
        self.agency        = agency
        self.adminPending  = founder
        self.minterPending = nil
        // Initialize variables
        self.request  <- {}
        self.copyright = {}
        self.admins    = {}
        self.agents    = {} 
        self.creators  = {}
        self.creatorCap = {}
        self.metadata  = {}
        self.newNFTs   = []
        // Counter varibbles
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        emit ContractInitialized()
	}
}