// daam_nft.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import FungibleToken    from 0xee82856bf20e2aa6 
import Profile          from 0x192440c99cb17282
/************************************************************************/
pub contract DAAM: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64,   to: Address?)

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
                 
    access(contract) var adminPending : Address?
    access(contract) var minterPending: Address?
    access(contract) var admins  : {Address: Bool}     // {Admin Address : status}
    access(contract) var creators: {Address: Bool}     // {Creator Address : status}
    access(contract) var metadata: {UInt64: Bool}      // {MID : Approved by Admin }
    access(contract) var request : @{UInt64: Request}  // {MID : @Request }

    pub var copyright: {UInt64: CopyrightStatus}       // {NFT.id : CopyrightStatus}
    
    access(contract) var collectionCounterID: UInt64
    access(contract) var metadataCounterID  : UInt64
    
    pub var newNFTs: [UInt64]    // {Creator : [UInt64]

    pub let agency: Address
/***********************************************************************/
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
            //pub case INCLUDED TODO v2
}
/***********************************************************************/
pub resource Request {
    access(contract) let mid       : UInt64
    access(contract) var royality  : {Address : UFix64}
    access(contract) var agreement : [Bool; 2]
    
    init(metadata: &Metadata) {
        self.mid       = metadata.mid
        self.royality  = {}
        self.agreement = [false, false] // [Admin, Creator] ,
    }

    pub fun getMID(): UInt64 { return self.mid }

    access(contract) fun bargin(signer: AuthAccount, mid: UInt64, royality: {Address:UFix64} ) {
        // Verify is Creator
        pre {
            signer.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath) != nil ||
            signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath) != nil : "You do not have access."

            royality.containsKey(DAAM.agency) : "Agency must be included in Royality."
            !self.isValid() : "Neogoation is already closed. Both parties have already agreed."
        }
        // 0 = creator, 1 = admin
        let selected   = signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath) != nil ? 0 : 1
        let unselected = signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath) != nil ? 1 : 0

        self.agreement[selected] = true
        self.agreement[unselected] = self.royalityMatch(royality)
        self.royality = royality

        log("Negotiating")
        if self.isValid() {
            log("Agreement Reached")
            emit AgreementReached(mid: mid)
        }
    }

    priv fun royalityMatch(_ royalities: {Address:UFix64} ): Bool {
        if self.royality.length != royalities.length { return false}
        for royality in royalities.keys {
            if royalities[royality] != self.royality[royality] { return false }
        }
        return true
    }

    access(contract) fun acceptDefault(royality: {Address:UFix64} ) {
        self.royality = royality
        self.agreement = [true, true]
    }

    pub fun isValid(): Bool { return self.agreement[0]==true && self.agreement[1]==true }
}    
/***********************************************************************/
pub resource RequestGenerator {
    
    init() {}

    pub fun createRequest(signer: AuthAccount, metadata: &Metadata, royality: {Address : UFix64} ) {
        pre {
            !DAAM.request.containsKey(metadata.mid) : "Already made request for this MID."
            metadata != nil
            royality.length > 1

            signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath) != nil ||
            signer.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath) != nil : "You do not have access"
        }
        let mid = metadata.mid
        let request <-! create Request(metadata: metadata)!
        request.bargin(signer: signer, mid: mid, royality: royality)

        let old <- DAAM.request.insert(key: mid, <-request) // advice DAAM of request
        destroy old
                    
        log("Royality Request: ".concat(mid.toString()) )
        emit RoyalityRequest(mid: mid)
    }

    pub fun acceptDefault(creator: AuthAccount, metadata: &Metadata) {
        let mid = metadata.mid
        var royality = {DAAM.agency: 0.05 as UFix64 }
        royality.insert(key: self.owner?.address!, 0.15 )

        let request <-! create Request(metadata: metadata)
        request.acceptDefault(royality: royality)

        let old <- DAAM.request.insert(key: mid, <-request) // advice DAAM of request
        destroy old
        
        log("Request Accepted, MID: ".concat(mid.toString()) )
        emit RequestAccepted(mid: mid)
    }

    pub fun getRequest(metadata: &MetadataHolder): @Request {
        pre {
            metadata != nil
            DAAM.request.containsKey(metadata.getMID() )
            DAAM.getRequestValidity(mid: metadata.getMID() )
        }
        let request <- DAAM.request.remove(key: metadata.metadata.mid)!
        return <- request
    }
}
/************************************************************************/
    pub struct Metadata {  // Metadata for NFT,metadata initialization
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
            self.mid       = DAAM.metadataCounterID
            self.creator   = creator
            self.series    = series
            self.counter   = counter
            self.data      = data
            self.thumbnail = thumbnail
            self.file      = file
        }
    }
/************************************************************************/
pub resource MetadataGenerator {
        access(contract) var metadata : {UInt64 : Metadata} // {mid : metadata}
        
        init() { self.metadata = {} }

        pub fun addMetadata(series: UInt64, data: String, thumbnail: String, file: String) {
            pre{
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
            }
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64  // Must be first/
            let creator = self.owner?.address!
            log("Creator: ".concat(creator.toString()) ) // DEBUG
            let metadata = Metadata(creator: creator, series: series, data: data, thumbnail: thumbnail,
                file: file, counter: 1 as UInt64)
            self.metadata.insert(key:metadata.mid, metadata)
            DAAM.metadata.insert(key: metadata.mid, false)
            DAAM.copyright.insert(key:metadata.mid, CopyrightStatus.UNVERIFIED)

            log("Metadata Generatated ID: ".concat(metadata.mid.toString()) )
            emit MetadataGeneratated()
        }

        pub fun removeMetadata(mid: UInt64) {
            pre {
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
                self.metadata[mid] != nil : "No Metadata entered"
            }
            self.metadata.remove(key: mid)
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)
        }

        pub fun generateMetadata(mid: UInt64): @MetadataHolder {
            pre {
                DAAM.creators.containsKey(self.owner?.address!) : "You are not a Creator"
                DAAM.creators[self.owner?.address!]!            : "Your Creator account is Frozen."
        
                self.metadata[mid] != nil : "No Metadata entered"
                DAAM.metadata[mid] != nil : "This already has been published."
                DAAM.metadata[mid]!       : "Your Submission was Rejected."
            }            
                        
            let ref = &self as &MetadataGenerator
            let mh <- create MetadataHolder(metadata: self.metadata[mid]!)

            if self.metadata[mid]!.counter == self.metadata[mid]?.series! && self.metadata[mid]?.series! != 0 as UInt64 {
                self.removeMetadata(mid: mid)
            } else {
                let counter = self.metadata[mid]!.counter + 1 as UInt64
                let new_metadata = Metadata(
                    creator: self.metadata[mid]?.creator!, series: self.metadata[mid]?.series!, data: self.metadata[mid]?.data!,
                    thumbnail: self.metadata[mid]?.thumbnail!, file: self.metadata[mid]?.file!, counter: self.metadata[mid]!.counter
                )
                self.metadata[mid] = new_metadata
            }
            return <- mh         
        }

        pub fun getMetadata(): &{UInt64:Metadata} {
            return &self.metadata as &{UInt64:Metadata}
        }

        pub fun getMetadataRef(mid: UInt64): &Metadata {
            pre { self.metadata[mid] != nil }
            return &self.metadata[mid] as &Metadata
        }
}
/************************************************************************/
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
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply
            self.royality = request.royality            
            self.metadata = metadata.metadata
            destroy metadata
        }

        pub fun getCopyright(): CopyrightStatus { return DAAM.copyright[self.id]! }
    }
/************************************************************************/
pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowDAAM(id: UInt64): &DAAM.NFT
}     
/************************************************************************/
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens. NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        pub let id: UInt64
                        
        init() {
            self.ownedNFTs <- {}
            DAAM.collectionCounterID = DAAM.collectionCounterID + 1 as UInt64
            self.id = DAAM.collectionCounterID
        }

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
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }        

        // borrowNFT gets a reference to an NFT in the collection so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
        }

        pub fun borrowDAAM(id: UInt64): &DAAM.NFT {
            pre { self.ownedNFTs[id] != nil }
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            return ref as! &DAAM.NFT
        }        

        destroy() { destroy self.ownedNFTs }
    }
/************************************************************************/
    pub resource interface Founder {
        pub fun inviteAdmin(newAdmin: Address) {
            pre{
                DAAM.adminPending == nil : "Admin already pending. Waiting on confirmation."
                Profile.check(newAdmin)  : "You can't add DAAM Admin without a Profile! Tell'em to make one first!!"
            }
            post { DAAM.adminPending != nil : "We're being hacked or something" }
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre {
                DAAM.creators.containsKey(creator) == false : "They're already a DAAM Creator!!!"
                Profile.check(creator) : "You can't be a DAAM Creator without a Profile! Go make one Fool!!"
            }
        }

        pub fun inviteMinter(_ minter: Address) 
        
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!"
                DAAM.creators[creator] != status   : "Creator already has this status."
            }
            post { DAAM.creators[creator] == status}
        }

        pub fun removeCreator(creator: Address) {
            pre  { DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!" }
            post { !DAAM.creators.containsKey(creator) }
        }

        pub fun removeAdmin(admin: Address)

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre  { DAAM.copyright.containsKey(mid): "This is an Invalid MID" }
            post { DAAM.copyright[mid] == copyright }
        }

        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre  { DAAM.copyright.containsKey(mid): "This is an Invalid MID" }
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
            DAAM.admins.insert(key: admin.address, true)
        }

        pub fun newRequestGenerator(): @RequestGenerator {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            return <- create RequestGenerator()
        }

        pub fun inviteAdmin(newAdmin: Address) {
            pre{
                self.status : "You're no longer a DAAM Admin!!"
                DAAM.creators[newAdmin] == nil: "An Admin can not use the same address as a Creator."
            }
            DAAM.adminPending = newAdmin
            log("Sent Admin Invation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.creators.insert(key: creator, false )
            log("Sent Creator Invation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)         
        }

        pub fun inviteMinter(_ minter: Address) {  // Admin add a new creator
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.minterPending = minter
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdminInvite() {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.adminPending = nil
            log("Admin Invation Removed")
            emit RemovedAdminInvite()                      
        }

        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre{ self.status : "This account is already frozen" }
            DAAM.creators[creator] = status
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }

        pub fun removeCreator(creator: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }            
            DAAM.creators.remove(key: creator)
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
                DAAM.admins.remove(key: admin)
                log("Removed Admin")
                emit AdminRemoved(admin: admin)
            }
        }

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.copyright[mid] = copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.metadata[mid] = status
        }    
	}
/************************************************************************/
    pub resource Creator {

        pub fun newMetadataGenerator(): @MetadataGenerator {
            pre{
                DAAM.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create MetadataGenerator()
        }

        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                DAAM.creators.containsKey(self.owner?.address!) : "You're not a Creator."
                DAAM.creators[self.owner?.address!] == true     : "This Creators' account is Frozen."
            }
            return <- create RequestGenerator()
        } 
    }
/************************************************************************/
    pub resource Minter {
        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(metadata: @MetadataHolder): @DAAM.NFT {
            pre{
                DAAM.creators.containsKey(metadata.metadata.creator) : "You're not a Creator."
                DAAM.creators[metadata.metadata.creator] == true     : "This Creators' account is Frozen."
                DAAM.request.containsKey(metadata.metadata.mid)      : "Invalid Request"
                DAAM.getRequestValidity(mid: metadata.metadata.mid)  : "There is no Request for this MID."
            }
            let isLast = metadata.metadata.counter == metadata.metadata.series
            let mid = metadata.metadata.mid
            let request <- DAAM.request.remove(key: mid)!
            let requestRef = &request as & Request
            let nft <- create NFT(metadata: <- metadata, request: requestRef)

            // Update Request, if last remove.
            if isLast {
                destroy request
            } else {
                let old_request <- DAAM.request.insert(key: mid, <- request)
                destroy old_request
            }            
            self.newNFT(id: nft.id)
            
            log("Minited NFT: ".concat(nft.id.toString()))
            emit MintedNFT(id: nft.id)

            return <- nft          
        }

        pub fun notNew(tokenID: UInt64) {
            pre  { DAAM.newNFTs.contains(tokenID)  }
            post { !DAAM.newNFTs.contains(tokenID) }
            var counter = 0
            for nft in DAAM.newNFTs {
                if nft == tokenID {
                    DAAM.newNFTs.remove(at: counter)
                    break
                } else {
                    counter = counter + 1
                }
            }
        }

        priv fun newNFT(id: UInt64) {
            pre  { !DAAM.newNFTs.contains(id) }
            post { DAAM.newNFTs.contains(id)  }
                DAAM.newNFTs.append(id)
        }        
    }
/************************************************************************/
    // DAAM Functions
    // public function that anyone can call to create a new empty collection
    pub fun answerAdminInvite(newAdmin: AuthAccount, submit: Bool): @Admin{Founder}? {
        pre {
            DAAM.creators[newAdmin.address] == nil: "An Admin can not use the same address as a Creator."
            DAAM.adminPending == newAdmin.address : "You got no DAAM Admin invite."
            Profile.check(newAdmin.address)       : "You can't be a DAAM Admin without a Profile first. Go make a Profile first."
        }
        DAAM.adminPending = nil
        if !submit { return nil }  
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin)!   
    }

    pub fun answerCreatorInvite(newCreator: AuthAccount, submit: Bool): @Creator? {
        pre {
            !DAAM.admins.containsKey(newCreator.address)  : "A Creator can not use the same address as an Admin."
            DAAM.creators.containsKey(newCreator.address) : "You got no DAAM Creator invite."
            Profile.check(newCreator.address)  : "You can't be a DAAM Creator without a Profile first. Go make a Profile first."
        }

        if !submit {
            DAAM.creators.remove(key: newCreator.address)
            return nil
        }
        
        DAAM.creators[newCreator.address] = submit        
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator()!
    }

    pub fun answerMinterInvite(minter: AuthAccount, submit: Bool): @Minter? {
        pre { DAAM.minterPending == minter.address }
        DAAM.minterPending = nil
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

    pub fun bargin(signer: AuthAccount, mid: UInt64, royality: {Address:UFix64} ) {
        // Verify is Creator
        pre {
            signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath) != nil ||
            signer.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath) != nil : "You do not have access."

            !self.getRequestValidity(mid: mid) : "Request already is settled."
        }

        let request <- self.request.remove(key: mid)!
        request.bargin(signer: signer, mid: mid, royality: royality)
        let old <- self.request[mid] <- request
        destroy old
    }
    
    pub fun getRequestMIDs(): [UInt64] {
        return DAAM.request.keys
    }

    pub fun isCreator(_ creator: Address): Bool? {
        //pre { creator == self.owner?.address! : "You may only verify your own address." } // TODO
        return self.creators[creator] // nil = not a creator, false = invited to be a creator, true = is a creator
    }

    pub fun isAdmin(_ admin: Address): Bool {
        //pre { admin == self.owner?.address! : "You may only verify your own address." } // TODO
        return self.admins.containsKey(admin)
    }

	init(agency: Address, founder: Address) {
        // init Paths
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

        self.agency        = agency
        self.adminPending  = founder
        self.minterPending = nil
        
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