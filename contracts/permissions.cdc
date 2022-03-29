// daam_nft.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import FungibleToken    from 0xee82856bf20e2aa6 
import Profile          from 0x192440c99cb17282
import Categories       from 0xfd43f9148d4b725d
/************************************************************************/
pub contract Permissions {
    // Events
    pub event ContractInitialized()
    
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

    
    access(contract) var metadata: {UInt64 : Bool}    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var metadataCap: {Address : Capability<&MetadataGenerator{MetadataGeneratorPublic}> }    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var request : @{UInt64: Request} // {MID : @Request } Request are stored here by MID
    access(contract) var copyright: {UInt64: CopyrightStatus} // {NFT.id : CopyrightStatus} Get Copyright Status by Token ID
    // Variables 
    access(contract) var newNFTs: [UInt64]    // A list of newly minted NFTs. 'New' is defined as 'never sold'. Age is Not a consideration.
    // Paths
    pub let adminPrivatePath      : PrivatePath  // Private path to Admin 
    pub let adminStoragePath      : StoragePath  // Storage path to Admin 
    pub let minterPrivatePath     : PrivatePath  // Private path to Minter
    pub let minterStoragePath     : StoragePath  // Storage path to Minter
    pub let creatorPrivatePath    : PrivatePath  // Private path to Creator
    pub let creatorStoragePath    : StoragePath  // Storage path to Creator
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
// mintNFT mints a new NFT and returns it.
// Note: new is defined by newly Minted. Age is not a consideration.
    pub resource Minter
    {
        priv let grantee: Address
        init(_ minter: AuthAccount) {
            self.grantee = minter.address
            DAAMDATA.minters.insert(key: minter.address, true) // Insert new Minter in minter list.
        }

        pub fun mintNFT(metadata: @MetadataHolder): @DAAM.NFT {
            pre{
                self.grantee == self.owner?.address! : "Permission Denied"
                metadata.metadata.counter <= metadata.metadata.series || metadata.metadata.series == 0 : "Internal Error: Mint Counter"
                DAAMDATA.creators.containsKey(metadata.metadata.creator) : "You're not a Creator."
                DAAMDATA.creators[metadata.metadata.creator] == true     : "This Creators' account is Frozen."
                DAAMDATA.request.containsKey(metadata.metadata.mid)      : "Invalid Request"
            }
            let isLast = metadata.metadata.counter == metadata.metadata.series // Get print count
            let mid = metadata.metadata.mid               // Get MID
            let nft <- create NFT(metadata: <- metadata, request: &DAAMDATA.request[mid] as &Request) // Create NFT

            // Update Request, if last remove.
            if isLast {
                let request <- DAAMDATA.request.remove(key: mid)! // Get Request using MID
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
                DAAMDATA.newNFTs.contains(tokenID)  : "This NFT is not a new NFT"
            }
            post { !DAAMDATA.newNFTs.contains(tokenID) : "Illegal Operation: notNew" } // Unreachable

            var counter = 0 as UInt64              // start the conter
            for nft in DAAMDATA.newNFTs {              // cycle through 'new' list
                if nft == tokenID {                // if Token ID is found
                    DAAMDATA.newNFTs.remove(at: counter) // remove from 'new' list
                    break
                } else {
                    counter = counter + 1          // increment counter
                }
            } // end for
        }

        // Add NFT to 'new' list
        priv fun newNFT(id: UInt64) {
            pre  { !DAAMDATA.newNFTs.contains(id) : "Token ID is already set to New." }
            post { DAAMDATA.newNFTs.contains(id)  : "Illegal Operation: newNFT" }
                DAAMDATA.newNFTs.append(id)       // Append 'new' list
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
            newAdmin.borrow<&DAAMDATA.Admin{DAAMDATA.Agent}>(from: self.adminStoragePath) == nil : "You are aleady an Admin."
            DAAMDATA.admins.containsKey(newAdmin.address)    : "You got no DAAM Admin invite."
            !DAAMDATA.agents.containsKey(newAdmin.address)   : "A Admin can not use the same address as an Agent."
            !DAAMDATA.creators.containsKey(newAdmin.address) : "A Admin can not use the same address as an Creator."
            Profile.check(newAdmin.address)  : "You can't be a DAAM Admin without a Profile first. Go make a Profile first."
        }

        if !submit { 
            DAAMDATA.admins.remove(key: newAdmin.address) // Release Admin
            return nil
        }  // Refused invitation. Return and end function
        
        // Invitation accepted at this point
        DAAMDATA.admins[newAdmin.address] = submit // Insert new Admin in admins list.
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin)!      // Accepted and returning Admin Resource
    }

    // // The Agent potential can accept (True) or deny (False)
    pub fun answerAgentInvite(newAgent: AuthAccount, submit: Bool): @Admin{Agent}?
    {
        pre {
            newAgent.borrow<&DAAMDATA.Admin{DAAMDATA.Agent}>(from: self.adminStoragePath) == nil : "You are aleady an Agent."
            !DAAMDATA.admins.containsKey(newAgent.address)   : "A Agent can not use the same address as an Admin."
            !DAAMDATA.creators.containsKey(newAgent.address) : "A Agent can not use the same address as an Creator."
            DAAMDATA.agents.containsKey(newAgent.address)    : "You got no DAAM Agent invite."
            Profile.check(newAgent.address)  : "You can't be a DAAM Agent without a Profile first. Go make a Profile first."
        }

        if !submit {                                  // Refused invitation. 
            DAAMDATA.agents.remove(key: newAgent.address) // Remove potential from Agent list
            return nil                                // Return and end function
        }
        // Invitation accepted at this point
        DAAMDATA.agents[newAgent.address] = submit        // Add Agent & set Status (True)
        log("Agent: ".concat(newAgent.address.toString()).concat(" added to DAAM") )
        emit NewAgent(agent: newAgent.address)
        return <- create Admin(newAgent)!             // Return Admin Resource as {Agent}
    }

    // // The Creator potential can accept (True) or deny (False)
    pub fun answerCreatorInvite(newCreator: AuthAccount, submit: Bool): @Creator? {
        pre {
            newCreator.borrow<&DAAMDATA.Creator>(from: self.creatorStoragePath) == nil : "You are aleady a Creator."
            !DAAMDATA.admins.containsKey(newCreator.address)  : "A Creator can not use the same address as an Admin."
            !DAAMDATA.agents.containsKey(newCreator.address)    : "A Creator can not use the same address as an Agent."
            DAAMDATA.creators.containsKey(newCreator.address) : "You got no DAAM Creator invite."
            Profile.check(newCreator.address)  : "You can't be a DAAM Creator without a Profile first. Go make a Profile first."
        }

        if !submit {                                       // Refused invitation.
            DAAMDATA.creators.remove(key: newCreator.address)  // Remove potential from Agent list
            return nil                                     // Return and end function
        }
        // Invitation accepted at this point
        DAAMDATA.creators[newCreator.address] = submit         // Add Creator & set Status (True)
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator(newCreator)!                         // Return Creator Resource
    }

    pub fun answerMinterInvite(minter: AuthAccount, submit: Bool): @Minter? {
        pre {
            minter.borrow<&DAAMDATA.Minter>(from: self.minterStoragePath) == nil : "You are aleady a Minter."
            DAAMDATA.minters.containsKey(minter.address) : "You do not have a Minter Invitation"
        }

        if !submit {                                 // Refused invitation. 
            DAAMDATA.minters.remove(key: minter.address) // Remove potential from Agent list
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
    pub fun createDAAMCollection(): @DAAMDATA.Collection {
        post { result.getIDs().length == 0: "The created DAAM collection must be empty!" }
        return <- create DAAMDATA.Collection() // Return Collection Resource
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
