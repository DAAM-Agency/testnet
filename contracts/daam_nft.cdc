// daam_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken    from 0x9a0766d93b6608b7 
import Profile          from 0xba1132bc08f82fe2
/************************************************************************/
pub contract DAAM_V3: NonFungibleToken
{
    pub var totalSupply: UInt64 // the total supply of NFTs, also used as counter for token ID
    // Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64,   to: Address?)
    // Events
    pub event NewAdmin(admin  : Address)
    pub event NewMinter(minter: Address)
    pub event NewCreator(creator: Address)
    pub event AdminInvited(admin  : Address)
    pub event CreatorInvited(creator: Address)
    pub event MinterSetup(minter: Address)   
    pub event MetadataGeneratated()
    pub event MintedNFT(id: UInt64)
    pub event ChangedCopyright(metadataID: UInt64)
    pub event RoyalityRequest(mid: UInt64)
    pub event ChangeCreatorStatus(creator: Address, status: Bool)
    pub event CreatorRemoved(creator: Address)
    pub event AdminRemoved(admin: Address)
    pub event RequestAnswered(mid: UInt64)
    pub event RequestAccepted(mid: UInt64)
    pub event RemovedMetadata(mid: UInt64)
    pub event RemovedAdminInvite()
    pub event AgreementReached(mid: UInt64)
    // Paths
    pub let collectionPublicPath  : PublicPath
    pub let collectionStoragePath : StoragePath
    pub let metadataPublicPath    : PublicPath
    pub let metadataStoragePath   : StoragePath
    pub let adminPrivatePath      : PrivatePath
    pub let adminStoragePath      : StoragePath
    pub let minterPrivatePath     : PrivatePath
    pub let minterStoragePath     : StoragePath
    pub let creatorPrivatePath    : PrivatePath
    pub let creatorStoragePath    : StoragePath
    pub let requestPrivatePath    : PrivatePath
    pub let requestStoragePath    : StoragePath
    // Variables
    access(contract) var adminPending : Address?       // Only 1 admin can be invited at a time
    access(contract) var minterPending: Address?       // Only 1 Minter can be invited at a time & there should only be one.
    access(contract) var admins  : {Address: Bool}     // {Admin Address : status}
    access(contract) var creators: {Address: Bool}     // {Creator Address : status}
    access(contract) var metadata: {UInt64: Bool}      // {MID : Approved by Admin }
    access(contract) var request : @{UInt64: Request}  // {MID : @Request }

    pub var copyright: {UInt64: CopyrightStatus}       // {NFT.id : CopyrightStatus}
    
    access(contract) var collectionCounterID: UInt64   // Gives Collection an ID number // V2 Preperation
    access(contract) var metadataCounterID  : UInt64   // The Metadta ID counter for MetadataID.
    
    pub var newNFTs: [UInt64]    // A list of newly minted NFTs. 'New' is defined as 'never sold' not age of NFT.
    pub let agency: Address      // DAAM Ageny Address
/***********************************************************************/
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
            //pub case INCLUDED // V2
}
/***********************************************************************/
// Used to make requests for royality. A resource for Neogoation of royalities.
// When both parties agree on 'royality' the Request is considered valid aka isValid() = true and
// Neogoation may not continue.
pub resource Request {
    access(contract) let mid       : UInt64                // Metadata ID number is stored
    access(contract) var royality  : {Address : UFix64}    // current royality neogoation.
    access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(metadata: &Metadata) {
        self.mid       = metadata.mid   // get Metadata ID
        self.royality  = {}             
        self.agreement = [false, false] // [Admin, Creator] are both set to disagree by default
    }

    pub fun getMID(): UInt64 { return self.mid }  // return Metadata ID

    // Accept Default royality. Skip Neogations.
    access(contract) fun acceptDefault(royality: {Address:UFix64} ) {
        self.royality = royality
        self.agreement = [true, true]
    }
    // If both parties agree (Creator & Admin) return true
    pub fun isValid(): Bool { return self.agreement[0]==true && self.agreement[1]==true }
}    
/***********************************************************************/
pub resource RequestGenerator
{ // Used to create 'Request's. Hardcodes/Incapcilates Metadata ID into Request.     
    init() {}

    // Accept the default Request. No Neogoation is required.
    pub fun acceptDefault(creator: AuthAccount, metadata: &Metadata, percentage: UFix64) {
        pre { percentage >= 0.1 && percentage <= 0.3 : "Percentage must be inbetween 10% to 30%." }

        let mid = metadata.mid                             // get MID
        var royality = {DAAM_V3.agency: (0.1 * percentage) }  // get Agency percentage, Agency takes 10% of Creator
        royality.insert(key: self.owner?.address!, (0.9 * percentage) ) // get Creator percentage

        let request <-! create Request(metadata: metadata)
        request.acceptDefault(royality: royality) 

        let old <- DAAM_V3.request.insert(key: mid, <-request) // advice DAAM of request
        destroy old
        
        log("Request Accepted, MID: ".concat(mid.toString()) )
        emit RequestAccepted(mid: mid)
    }
    // Get the Request resource, exclusive for Minting
    pub fun getRequest(metadata: &MetadataHolder): @Request {
        pre {
            metadata != nil
            DAAM_V3.request.containsKey(metadata.getMID() )
            DAAM_V3.getRequestValidity(mid: metadata.getMID() )
        }
        let request <- DAAM_V3.request.remove(key: metadata.metadata.mid)!
        return <- request
    }
}
/************************************************************************/
    pub struct Metadata {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let mid       : UInt64
        pub let creator   : Address  // Creator
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let data      : String   // JSON see metadata.json
        pub let thumbnail : String   // JSON see metadata.json
        pub let file      : String   // JSON see metadata.json
        
        init(creator: Address, series: UInt64, data: String, thumbnail: String, file: String, counter: UInt64) {
            pre {
                counter != 0 as UInt64 : "Illegal operation."
                (series != 0 && counter <= series) || series == 0 : "Reached limit on prints."
            }
            self.mid       = DAAM_V3.metadataCounterID
            self.creator   = creator
            self.series    = series
            self.counter   = counter
            self.data      = data
            self.thumbnail = thumbnail
            self.file      = file
        }
    }
/************************************************************************/
pub resource MetadataGenerator
{ // Verifies each Metadata get a Metadata ID, and stores the Creators' Metadatas'.

        access(contract) var metadata : {UInt64 : Metadata} // {mid : metadata}        
        init() { self.metadata = {} }

        // addMetadata: Used to add a new Metadata. This sets up the Metadata to be approved by the Admin
        pub fun addMetadata(series: UInt64, data: String, thumbnail: String, file: String) {
            pre{
                DAAM_V3.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM_V3.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
            }
            DAAM_V3.metadataCounterID = DAAM_V3.metadataCounterID + 1 as UInt64  // Must be first/
            let creator = self.owner?.address!
            let metadata = Metadata(creator: creator, series: series, data: data, thumbnail: thumbnail,
                file: file, counter: 1 as UInt64)
            self.metadata.insert(key:metadata.mid, metadata) // save Metadata
            DAAM_V3.metadata.insert(key: metadata.mid, false)   // accounce metadata as unapproved
            DAAM_V3.copyright.insert(key:metadata.mid, CopyrightStatus.UNVERIFIED) // default copyright setting

            log("Metadata Generatated ID: ".concat(metadata.mid.toString()) )
            emit MetadataGeneratated()
        }
        // Used to remove Metadata from the Creators metadata dictionary list.
        pub fun removeMetadata(mid: UInt64) {
            pre {
                DAAM_V3.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM_V3.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
            }
            self.metadata.remove(key: mid) // Metadata removed. Metadata Template has reached its max count (series)
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)
        }
        // Remove Metadata as Resource MetadataHolder. MetadataHolder + Request = NFT.
        // The MetadataHolder will be destroyed along with a matching Request (same MID) in order to create the NFT
        pub fun generateMetadata(mid: UInt64): @MetadataHolder {
            pre {
                DAAM_V3.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM_V3.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
                DAAM_V3.metadata[mid] != nil : "This already has been published."
                DAAM_V3.metadata[mid]!       : "Your Submission was Rejected."
            }            
                        
            let ref = &self as &MetadataGenerator
            let mh <- create MetadataHolder(metadata: self.metadata[mid]!) // Create Current Metadata
            // Verify Current Metadata print (counter) do not exceed series limit; if last ...
            if self.metadata[mid]!.counter == self.metadata[mid]?.series! && self.metadata[mid]?.series! != 0 as UInt64 {
                self.removeMetadata(mid: mid) // ... remove metadata template
            } else {
                let counter = self.metadata[mid]!.counter + 1 as UInt64
                let new_metadata = Metadata(
                    creator: self.metadata[mid]?.creator!, series: self.metadata[mid]?.series!, data: self.metadata[mid]?.data!,
                    thumbnail: self.metadata[mid]?.thumbnail!, file: self.metadata[mid]?.file!, counter: self.metadata[mid]!.counter
                ) // prep Next Vetadata
                self.metadata[mid] = new_metadata
            }
            return <- mh // return Current Metadata  
        }

        pub fun getMetadata(): &{UInt64:Metadata} {  // return all Creators' Metadata
            return &self.metadata as &{UInt64:Metadata}
        }

        pub fun getMetadataRef(mid: UInt64): &Metadata { // return specific Creators' Metadata
            pre { self.metadata[mid] != nil }
            return &self.metadata[mid] as &Metadata
        }
}
/************************************************************************/
// Resource used to transport Metadata. Verifies MID is valid
    pub resource MetadataHolder {        
        access(contract) var metadata: Metadata
        init (metadata: Metadata) {
            pre { metadata != nil }              
            self.metadata = metadata
        }
        pub fun getMID(): UInt64 { return self.metadata.mid }
    }
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT {
        pub let id       : UInt64
        pub let metadata : Metadata
        pub let royality : {Address : UFix64}

        init(metadata: @MetadataHolder, request: &Request) {
            pre { metadata.metadata.mid == request.mid }
            DAAM_V3.totalSupply = DAAM_V3.totalSupply + 1 as UInt64
            self.id = DAAM_V3.totalSupply
            self.royality = request.royality            
            self.metadata = metadata.metadata
            destroy metadata
        }

        pub fun getCopyright(): CopyrightStatus {
            return DAAM_V3.copyright[self.id]!
        }
    }
/************************************************************************/
pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowDAAM(id: UInt64): &DAAM_V3.NFT
}     
/************************************************************************/
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens. NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        pub let id: UInt64
                        
        init() {
            self.ownedNFTs <- {}
            DAAM_V3.collectionCounterID = DAAM_V3.collectionCounterID + 1 as UInt64
            self.id = DAAM_V3.collectionCounterID
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @DAAM_V3.NFT
            let id: UInt64 = token.id
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }        

        // borrowNFT gets a reference to an NonFungibleToken.NFT in the collection so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
        }
        // borrowDAAM gets a reference to an DAAM.NFT in the collection so that the caller can read its metadata and call its methods
        pub fun borrowDAAM(id: UInt64): &DAAM_V3.NFT {
            pre { self.ownedNFTs[id] != nil }
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            return ref as! &DAAM_V3.NFT
        }        

        destroy() { destroy self.ownedNFTs }
    }
/************************************************************************/
    pub resource interface Founder {
        pub fun inviteAdmin(newAdmin: Address) {
            pre{
                DAAM_V3.adminPending == nil : "Admin already pending. Waiting on confirmation."
                Profile.check(newAdmin)  : "You can't add DAAM Admin without a Profile! Tell'em to make one first!!"
            }
            post { DAAM_V3.adminPending != nil : "We're being hacked or something" }
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre {
                DAAM_V3.creators.containsKey(creator) == false : "They're already a DAAM Creator!!!"
                Profile.check(creator) : "You can't be a DAAM Creator without a Profile! Go make one Fool!!"
            }
        }

        pub fun inviteMinter(_ minter: Address) 
        
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                DAAM_V3.creators.containsKey(creator) : "They're no DAAM Creator!!!"
                DAAM_V3.creators[creator] != status   : "Creator already has this status."
            }
            post { DAAM_V3.creators[creator] == status}
        }

        pub fun removeCreator(creator: Address) {
            pre  { DAAM_V3.creators.containsKey(creator) : "They're no DAAM Creator!!!" }
            post { !DAAM_V3.creators.containsKey(creator) }
        }

        pub fun removeAdmin(admin: Address)

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre  { DAAM_V3.copyright.containsKey(mid): "This is an Invalid MID" }
            post { DAAM_V3.copyright[mid] == copyright }
        }

        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre  { DAAM_V3.copyright.containsKey(mid): "This is an Invalid MID" }
        }

        pub fun removeAdminInvite()

        pub fun newRequestGenerator(): @RequestGenerator
    }
/************************************************************************/
	pub resource Admin: Founder
    {
        priv var status: Bool
        priv var remove: [Address]

        init(_ admin: AuthAccount) {
            self.status = true
            self.remove = []
            DAAM_V3.admins.insert(key: admin.address, true)
        }

        pub fun newRequestGenerator(): @RequestGenerator {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            return <- create RequestGenerator()
        }

        pub fun inviteAdmin(newAdmin: Address) {
            pre{
                self.status : "You're no longer a DAAM Admin!!"
                DAAM_V3.creators[newAdmin] == nil: "An Admin can not use the same address as a Creator."
            }
            DAAM_V3.adminPending = newAdmin
            log("Sent Admin Invation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM_V3.creators.insert(key: creator, false )
            log("Sent Creator Invation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)         
        }

        pub fun inviteMinter(_ minter: Address) {  // Admin add a new creator
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM_V3.minterPending = minter
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdminInvite() {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM_V3.adminPending = nil
            log("Admin Invation Removed")
            emit RemovedAdminInvite()                      
        }

        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre{ self.status : "This account is already frozen" }
            DAAM_V3.creators[creator] = status
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }

        pub fun removeCreator(creator: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }            
            DAAM_V3.creators.remove(key: creator)
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        pub fun removeAdmin(admin: Address) {
            pre{
                self.status : "You're no longer a DAAM Admin!!"
                !self.remove.contains(admin) : "You already did"
            }
            self.remove.append(admin)
            if self.remove.length >= 2 {
                self.status = false
                // TODO make Admin self destruct
                DAAM_V3.admins.remove(key: admin)
                log("Removed Admin")
                emit AdminRemoved(admin: admin)
            }
        }

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM_V3.copyright[mid] = copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM_V3.metadata[mid] = status
        }    
	}
/************************************************************************/
    pub resource Creator {

        pub fun newMetadataGenerator(): @MetadataGenerator {
            pre{
                DAAM_V3.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM_V3.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create MetadataGenerator()
        }

        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                DAAM_V3.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM_V3.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create RequestGenerator()
        } 
    }
/************************************************************************/
    pub resource Minter {
        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(metadata: @MetadataHolder): @DAAM_V3.NFT {
            pre{
                DAAM_V3.creators.containsKey(metadata.metadata.creator) : "You're not a Creator."
                DAAM_V3.creators[metadata.metadata.creator] == true     : "This Creators' account is Frozen."
                DAAM_V3.request.containsKey(metadata.metadata.mid)      : "Invalid Request"
                DAAM_V3.getRequestValidity(mid: metadata.metadata.mid)  : "There is no Request for this MID."
            }
            let isLast = metadata.metadata.counter == metadata.metadata.series
            let mid = metadata.metadata.mid
            let request <- DAAM_V3.request.remove(key: mid)!
            let requestRef = &request as & Request
            let nft <- create NFT(metadata: <- metadata, request: requestRef)

            // Update Request, if last remove.
            if isLast {
                destroy request
            } else {
                let old_request <- DAAM_V3.request.insert(key: mid, <- request)
                destroy old_request
            }            
            self.newNFT(id: nft.id)
            
            log("Minited NFT: ".concat(nft.id.toString()))
            emit MintedNFT(id: nft.id)

            return <- nft          
        }

        // Removes token from 'new' list. 'new' is defines as not sold, not based on age.
        pub fun notNew(tokenID: UInt64) {
            pre  { DAAM_V3.newNFTs.contains(tokenID)  }
            post { !DAAM_V3.newNFTs.contains(tokenID) }
            var counter = 0
            for nft in DAAM_V3.newNFTs {
                if nft == tokenID {
                    DAAM_V3.newNFTs.remove(at: counter)
                    break
                } else {
                    counter = counter + 1
                }
            }
        }

        // add NFT to 'new' list
        priv fun newNFT(id: UInt64) {
            pre  { !DAAM_V3.newNFTs.contains(id) }
            post { DAAM_V3.newNFTs.contains(id)  }
                DAAM_V3.newNFTs.append(id)
        }        
    }
/************************************************************************/
    // public DAAM functions that anyone can call 
    pub fun answerAdminInvite(newAdmin: AuthAccount, submit: Bool): @Admin{Founder}? {
        pre {
            DAAM_V3.creators[newAdmin.address] == nil: "An Admin can not use the same address as a Creator."
            DAAM_V3.adminPending == newAdmin.address : "You got no DAAM Admin invite."
            Profile.check(newAdmin.address)       : "You can't be a DAAM Admin without a Profile first. Go make a Profile first."
        }
        DAAM_V3.adminPending = nil
        if !submit { return nil }  
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin)!   
    }

    pub fun answerCreatorInvite(newCreator: AuthAccount, submit: Bool): @Creator? {
        pre {
            !DAAM_V3.admins.containsKey(newCreator.address)  : "A Creator can not use the same address as an Admin."
            DAAM_V3.creators.containsKey(newCreator.address) : "You got no DAAM Creator invite."
            Profile.check(newCreator.address)  : "You can't be a DAAM Creator without a Profile first. Go make a Profile first."
        }

        if !submit {
            DAAM_V3.creators.remove(key: newCreator.address)
            return nil
        }
        
        DAAM_V3.creators[newCreator.address] = submit        
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator()!
    }

    pub fun answerMinterInvite(minter: AuthAccount, submit: Bool): @Minter? {
        pre { DAAM_V3.minterPending == minter.address }
        DAAM_V3.minterPending = nil
        if !submit { return nil }        
        log("Minter: ".concat(minter.address.toString()) )
        emit NewMinter(minter: minter.address)
        return <- create Minter()!     
    }
    
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        post { result.getIDs().length == 0: "The created collection must be empty!" }
        return <- create Collection()
    }

    pub fun getRequestValidity(mid: UInt64): Bool {
        pre { self.request.containsKey(mid)}
        return self.request[mid]?.isValid() == true ? true : false
    }

    pub fun getRequestMIDs(): [UInt64] {
        return DAAM_V3.request.keys
    }

    pub fun isCreator(_ creator: Address): Bool? {
        return self.creators[creator] // nil = not a creator, false = invited to be a creator, true = is a creator
    }

    pub fun isAdmin(_ admin: Address): Bool {
        return self.admins.containsKey(admin)
    }

/************************************************************************/
	// TESTNET ONLY FUNCTIONS !!!! // TODO REMOVE

    pub fun resetAdmin(_ admin: Address) {
        self.adminPending = admin
    }

    // END TESNET FUNCTIONS
/************************************************************************/
    
    init(agency: Address, founder: Address) {
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
        // internal agency values
        self.agency        = agency
        self.adminPending  = founder
        self.minterPending = nil  // Consider making argument... not likely
        
        self.request  <- {}
        self.copyright = {}
        self.admins    = {}
        self.creators  = {}
        self.metadata  = {}
        self.newNFTs   = []
       
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.collectionCounterID = 0  // Incremental Serial Number for the Collections
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        emit ContractInitialized()
	}
}