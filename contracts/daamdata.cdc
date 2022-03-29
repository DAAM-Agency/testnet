// daam_nft.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import FungibleToken    from 0xee82856bf20e2aa6 
import Profile          from 0x192440c99cb17282
import Categories       from 0xfd43f9148d4b725d
/************************************************************************/
pub contract DAAMDATA {
    // Events
    pub event ContractInitialized()
    pub event AddMetadata(creator: Address, mid: UInt64) // Metadata Added
    pub event RemovedMetadata(mid: UInt64)       // Metadata has been removed by Creator

    // Paths
    pub let metadataPrivatePath   : PublicPath   // Public path that to Metadata Generator: Requires Admin/Agent  or Creator Key
    pub let metadataStoragePath   : StoragePath  // Storage path to Metadata Generator
    // Variables 
    access(contract) var metadataCounterID : UInt64   // The Metadta ID counter for MetadataID.
    // Variables
    access(contract) var metadata: {UInt64 : Bool}    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var metadataCap: {Address : Capability<&MetadataGenerator{MetadataGeneratorPublic}> }    // {MID : Approved by Admin } Metadata ID status is stored here
//    access(contract) var request : @{UInt64: Request} // {MID : @Request } Request are stored here by MID
    //access(contract) var copyright: {UInt64: CopyrightStatus} // {NFT.id : CopyrightStatus} Get Copyright Status by Token ID
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
// Neogoation may not continue. V2 Featur TODO
// Request manage the royality rate
// Accept Default are auto agreements
pub resource Request {
    access(contract) let mid       : UInt64                // Metadata ID number is stored
    access(contract) var royality  : {Address : UFix64}    // current royality neogoation.
    access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(mid: UInt64) {
        self.mid       = mid             // Get Metadata ID
        DAAMDATA.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
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
    pub fun acceptDefault(creator: AuthAccount, mid: UInt64, metadataGen: &MetadataGenerator{MetadataGeneratorPublic}, percentage: UFix64) {
        pre {
            self.grantee == creator.address            : "Permission Denied"
            metadataGen.getMetadata().containsKey(mid) : "Wrong MID"
            DAAMDATA.creators.containsKey(creator.address) : "You are not a Creator"
            DAAMDATA.creators[creator.address]!            : "Your Creator account is Frozen."
            percentage >= 0.1 && percentage <= 0.3 : "Percentage must be inbetween 10% to 30%."
        }

        var royality = {DAAMDATA.agency: (0.1 * percentage) }  // get Agency percentage, Agency takes 10% of Creator
        royality.insert(key: self.owner?.address!, (0.9 * percentage) ) // get Creator percentage

        let request <-! create Request(mid: mid) // get request
        request.acceptDefault(royality: royality)          // append royality rate

        let old <- DAAMDATA.request.insert(key: mid, <-request) // advice DAAM of request
        destroy old // destroy place holder
        
        log("Request Accepted, MID: ".concat(mid.toString()) )
        emit RequestAccepted(mid: mid)
    }
}
/************************************************************************/
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
                DAAMDATA.metadataCounterID = DAAMDATA.metadataCounterID + 1
                self.mid = DAAMDATA.metadataCounterID
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

        pub fun activate(creator: AuthAccount) {
            pre{
                self.grantee == creator.address                : "Permission Denied"
                DAAMDATA.creators.containsKey(creator.address)     : "You are not a Creator"
                !DAAMDATA.metadataCap.containsKey(creator.address) : "This Metadata Generator is already Activated."
            }
            DAAMDATA.metadataCap.insert(key: self.grantee,getAccount(self.grantee).getCapability<&MetadataGenerator{MetadataGeneratorPublic}>(DAAMDATA.metadataPrivatePath))
            // Adding Metadata Capability
        }

        // addMetadata: Used to add a new Metadata. This sets up the Metadata to be approved by the Admin. Returns the new mid.
        pub fun addMetadata(creator: AuthAccount, series: UInt64, categories: [Categories.Category], data: String, thumbnail: String, file: String): UInt64 {
            pre{
                self.grantee == creator.address            : "Permission Denied"
                DAAMDATA.creators.containsKey(creator.address) : "You are not a Creator"
                DAAMDATA.creators[creator.address]!            : "Your Creator account is Frozen."
            }
            let metadata = Metadata(creator: creator.address, series: series, categories: categories, data: data, thumbnail: thumbnail,
                file: file, counter: nil) // Create Metadata
            let mid = metadata.mid
            self.metadata.insert(key: mid, metadata) // Save Metadata
            DAAMDATA.metadata.insert(key: mid, false)   // a metadata ID for Admin approval, currently unapproved (false)
            DAAMDATA.copyright.insert(key: mid, CopyrightStatus.UNVERIFIED) // default copyright setting

            DAAMDATA.metadata[mid] = true // TODO REMOVE AUTO-APPROVE AFTER DEVELOPEMNT

            log("Metadata Generatated ID: ".concat(mid.toString()) )
            emit AddMetadata(creator: creator.address, mid: mid)
            return mid
        }

        // RemoveMetadata uses deleteMetadata to delete the Metadata.
        // But when deleting a submission the request must also be deleted.
        pub fun removeMetadata(creator: AuthAccount, mid: UInt64) {
            pre {
                self.grantee == self.owner?.address!       : "Permission Denied"
                DAAMDATA.creators.containsKey(creator.address) : "You are not a Creator"
                DAAMDATA.creators[creator.address]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
            }
            self.deleteMetadata(mid: mid)  // Delete Metadata
            let old_request <- DAAMDATA.request.remove(key: mid)  // Get Request
            destroy old_request // Delete Request
        }

        // Used to remove Metadata from the Creators metadata dictionary list.
        priv fun deleteMetadata(mid: UInt64) {
            self.metadata.remove(key: mid) // Metadata removed. Metadata Template has reached its max count (series)
            DAAMDATA.metadata.remove(key: mid) // Metadata removed from DAAMDATA. Logging no longer neccessary
            DAAMDATA.copyright.remove(key:mid) // remove metadata copyright            
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)
        }
        // Remove Metadata as Resource MetadataHolder. MetadataHolder + Request = NFT.
        // The MetadataHolder will be destroyed along with a matching Request (same MID) in order to create the NFT
        pub fun generateMetadata(minter: PublicAccount, mid: UInt64) : @MetadataHolder {
            pre {
                self.grantee == self.owner?.address!            : "Permission Denied"
                DAAMDATA.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAMDATA.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
                DAAMDATA.metadata[mid] != nil : "This already has been published."
                DAAMDATA.metadata[mid]!       : "Your Submission was Rejected."
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
/***********************************************************************/
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
                DAAMDATA.creators[newAdmin] == nil : "A Admin can not use the same address as an Creator."
                DAAMDATA.agents[newAdmin] == nil   : "A Admin can not use the same address as an Agent."
                DAAMDATA.admins[newAdmin] == nil   : "They're already sa DAAM Admin!!!"
                Profile.check(newAdmin) : "You can't be a DAAM Admin without a Profile! Go make one Fool!!"
            }
            post { DAAMDATA.admins[newAdmin] == false : "Illegal Operaion: inviteAdmin" }

            DAAMDATA.admins.insert(key: newAdmin, false) // Admin account is setup but not active untill accepted.
            log("Sent Admin Invitation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteAgent(_ agent: Address) {    // Admin ivites new Agent
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                 : "You're no longer a have Access."
                DAAMDATA.admins[agent] == nil   : "A Agent can not use the same address as an Admin."
                DAAMDATA.creators[agent] == nil : "A Agent can not use the same address as an Creator."
                DAAMDATA.agents[agent] == nil   : "They're already a DAAM Agent!!!"
                Profile.check(agent) : "You can't be a DAAM Admin without a Profile! Go make one Fool!!"
            }
            post { DAAMDATA.agents[agent] == false : "Illegal Operaion: inviteAdmin" }

            DAAMDATA.agents.insert(key: agent, false ) // Agent account is setup but not active untill accepted.
            log("Sent Agent Invitation: ".concat(agent.toString()) )
            emit AgentInvited(agent: agent)         
        }

        pub fun inviteCreator(_ creator: Address) {    // Admin or Agent invite a new creator
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                   : "You're no longer a have Access."
                DAAMDATA.admins[creator]   == nil : "A Creator can not use the same address as an Admin."
                DAAMDATA.agents[creator]   == nil : "A Creator can not use the same address as an Agent."
                DAAMDATA.creators[creator] == nil : "They're already a DAAM Creator!!!"
                Profile.check(creator) : "You can't be a DAAM Creator without a Profile! Go make one Fool!!"
            }
            post { DAAMDATA.creators[creator] == false : "Illegal Operaion: inviteCreator" }

            DAAMDATA.creators.insert(key: creator, false ) // Creator account is setup but not active untill accepted.

            log("Sent Creator Invitation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)      
        }

        pub fun inviteMinter(_ minter: Address) {   // Admin invites a new Minter (Key)
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status : "You're no longer a have Access."
            }
            post { DAAMDATA.minters[minter] == false : "Illegal Operaion: inviteCreator" }

            DAAMDATA.minters.insert(key: minter, false) // Minter Key is setup but not active untill accepted.
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdmin(admin: Address) { // Two Admin to Remove Admin
            pre  {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status: "You're no longer a have Access."
            }

            let vote = 2 as Int // TODO change to 3
            DAAMDATA.remove.insert(key: self.owner?.address!, admin) // Append removal list
            if DAAMDATA.remove.length >= vote {                      // If votes is 3 or greater
                var counter: {Address: Int} = {} // {To Remove : Total Votes}
                // Talley Votes
                for a in DAAMDATA.remove.keys {
                    let remove = DAAMDATA.remove[a]! // get To Remove
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
                        DAAMDATA.remove = {}           // Reset DAAMDATA.Remove
                        DAAMDATA.admins.remove(key: c) // Remove selected Admin
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
                DAAMDATA.agents.containsKey(agent) : "This is not a Agent Address."
            }
            post { !DAAMDATA.agents.containsKey(agent) : "Illegal operation: removeAgent" } // Unreachable

            DAAMDATA.agents.remove(key: agent)    // Remove Agent from list
            log("Removed Agent")
            emit AgentRemoved(agent: agent)
        }

        pub fun removeCreator(creator: Address) { // Admin removes selected Creator by Address
            pre {  
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                        : "You're no longer a have Access."
                DAAMDATA.creators.containsKey(creator) : "This is not a Creator address."
            }
            post { !DAAMDATA.creators.containsKey(creator) : "Illegal operation: removeCreator" } // Unreachable

            DAAMDATA.creators.remove(key: creator)    // Remove Creator from list
            DAAMDATA.metadataCap.remove(key: creator) // Remove Metadata Capability from list
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        pub fun removeMinter(minter: Address) { // Admin removes selected Agent by Address
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                      : "You're no longer a have Access."
                DAAMDATA.minters.containsKey(minter) : "This is not a Minter Address."
            }
            post { !DAAMDATA.minters.containsKey(minter) : "Illegal operation: removeAgent" } // Unreachable
            DAAMDATA.minters.remove(key: minter)    // Remove Agent from list
            log("Removed Minter")
            emit MinterRemoved(minter: minter)
        }

        // Admin can Change Agent status 
        pub fun changeAgentStatus(agent: Address, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                     : "You're no longer a have Access."
                DAAMDATA.agents.containsKey(agent)  : "Wrong Address. This is not an Agent."
                DAAMDATA.agents[agent] != status    : "Agent already has this Status."
            }
            post { DAAMDATA.agents[agent] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAMDATA.agents[agent] = status // status changed
            log("Agent Status Changed")
            emit ChangeAgentStatus(agent: agent, status: status)
        }        

        // Admin or Agent can Change Creator status 
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                         : "You're no longer a have Access."
                DAAMDATA.creators.containsKey(creator)  : "Wrong Address. This is not a Creator."
                DAAMDATA.creators[creator] != status    : "Agent already has this Status."
            }
            post { DAAMDATA.creators[creator] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAMDATA.creators[creator] = status // status changed
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }

        // Admin can Change Minter status 
        pub fun changeMinterStatus(minter: Address, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                       : "You're no longer a have Access."
                DAAMDATA.minters.containsKey(minter)  : "Wrong Address. This is not a Minter."
                DAAMDATA.minters[minter] != status    : "Minter already has this Status."
            }
            post { DAAMDATA.minters[minter] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAMDATA.minters[minter] = status // status changed
            log("Minter Status Changed")
            emit ChangeMinterStatus(minter: minter, status: status)
        }         

        // Admin or Agent can change a MIDs copyright status.
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAMDATA.copyright.containsKey(mid)      : "This is an Invalid MID"
            }
            post { DAAMDATA.copyright[mid] == copyright  : "Illegal Operation: changeCopyright" } // Unreachable

            DAAMDATA.copyright[mid] = copyright    // Change to new copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        // Get all MIDs & their Status
        pub fun getMetadataStatus(): {UInt64:Bool} { // { MID : Status}
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
            }
            return DAAMDATA.metadata
        }
        // Mainly for testing, Considering Removing TODO
        pub fun getMetadatasRef(creator: Address): {UInt64 :DAAMDATA} {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAMDATA.creators[creator] != nil        : "You have not selected a Creator."
            }
            let mCap = DAAMDATA.metadataCap[creator]!.borrow()! as &MetadataGenerator{MetadataGeneratorPublic}
            return mCap.getMetadata()
        }
        // Mainly for testing, Considering Removing TODO
        pub fun getMetadataRef(creator: Address, mid: UInt64):DAAMDATA {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAMDATA.creators[creator] != nil        : "You have not selected a Creator."
                DAAMDATA.metadata.containsKey(mid)       : "Incorrect MID"
            }
            let mCap = DAAMDATA.metadataCap[creator]!.borrow()! as &MetadataGenerator{MetadataGeneratorPublic}
            return mCap.getMetadata()[mid]!
        }

        // Admin or Agent can change a Metadata status.
        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre {
                self.grantee == self.owner?.address! : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAMDATA.copyright.containsKey(mid)      : "This is an Invalid MID"
            }            
            DAAMDATA.metadata[mid] = status // change to a new Metadata status
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
                DAAMDATA.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAMDATA.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create MetadataGenerator(self.grantee) // return Metadata Generator
        }

        // Used to create a Request Generator when initalizing Creator Storge
        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                self.grantee == self.owner?.address! : "Permission Denied"
                DAAMDATA.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAMDATA.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create RequestGenerator(self.grantee) // return Request Generator
        } 
    }
/************************************************************************/
    // Public DAAM functions

/************************************************************************/
// Init DAAM Contract variables
    
    init(agency: Address, founder: Address)
    {
        // Paths
        
        self.metadataPrivatePath   = /public/DAAM_SubmitNFT
        self.metadataStoragePath   = /storage/DAAM_SubmitNFT
        // Initialize variables
        self.metadata  = {}
        self.metadataCap = {}
        // Counter varibbles
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        emit ContractInitialized()
	}
}
