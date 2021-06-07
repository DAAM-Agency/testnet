// daam_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import FungibleToken    from 0xee82856bf20e2aa6
import Profile          from 0x192440c99cb17282
/************************************************************************/
pub contract DAAM: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64,   to: Address?)

    pub event NewAdmin(admin  : Address)
    pub event NewCreator(creator: Address)
    pub event AdminInvited(admin  : Address)
    pub event CreatorInvited(creator: Address)
    pub event MetadataGeneratated(creator: Address, id: UInt64)
    pub event MintedNFT(id: UInt64)
    pub event ChangedCopyright(metadataID: UInt64)
    pub event RoyalityRequest(receiver: Address)
    pub event ChangeCreatorStatus(creator: Address, status: Bool)
    pub event CreatorRemoved(creator: Address)
    pub event AdminRemoved(admin: Address)
    pub event RequestAnswered(mid: UInt64)
    pub event RemovedAdminInvite()

    pub let collectionPublicPath : PublicPath
    pub let collectionStoragePath: StoragePath
    pub let metadataPublicPath   : PublicPath
    pub let metadataStoragePath  : StoragePath
    pub let adminStoragePath     : StoragePath
    pub let adminPrivatePath     : PrivatePath
    pub let creatorStoragePath   : StoragePath
    pub let creatorPrivatePath   : PrivatePath
                 
    access(contract) var adminPending : Address?
    access(contract) var creators: {Address: Bool} // {request as a string : Address List}
    access(contract) var metadata: {UInt64: Bool}

    pub var copyright: {UInt64: CopyrightStatus}      // {NFT.id : CopyrightStatus}
    
    access(contract) var collectionCounterID: UInt64
    access(contract) var metadataCounterID  : UInt64

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
pub resource RequestGenerator {
    priv var request  : {UInt64 : Request}  // { mid : Request }
    pub var to        : {UInt64 : Address}  // { mid : Address }

    init(request: Request, to: Address) {
        self.request = {}
        self.to      = {}
        self.request.insert(key: request.mid, request)
        self.to.insert(key: request.mid, to)
    }

    pub fun makeRequest(metadata: &Metadata, royality: {Address : UFix64}, send: Address) {
        // TODO Verify sender is a Creator or Admin
            let request = Request(mid: metadata.mid, royality: royality)
            self.request[request.mid] = request
            self.to[request.mid] = send
                       
            log("Royality Request: ".concat(send.toString()) )
            emit RoyalityRequest(receiver: send)
    }

    pub fun answerRequest(mid: UInt64, answer: Bool): @RequestHolder? {
            let request = self.request[mid]
            let to = self.to[mid]
            if answer {
                let rh <- create RequestHolder(request: request!)
                log("Request Answered, MID: ".concat(mid.toString()) )
                emit RequestAnswered(mid: mid)
                return <- rh
            }
            return nil       
        }
}
/***********************************************************************/
pub struct Request {
    pub let mid       : UInt64
    pub let royality  : {Address : UFix64}
    //pub var price   : UFix64?

    init(mid: UInt64, royality: {Address : UFix64} ) {
        self.mid      = mid
        self.royality = royality
    }
}
/***********************************************************************/
    pub resource RequestHolder {        
        access(contract) var request: Request
        init (request: Request) { self.request = request }
        pub fun getMID(): UInt64 { return self.request.mid }
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
        
        init(creator: Address, series: UInt64, data: String, thumbnail: String, file: String, metadata: Metadata?) {
            post{ self.counter <= self.series }
            if metadata == nil { // new
                self.mid       = DAAM.metadataCounterID
                self.creator   = creator
                self.series    = series
                self.counter   = 0 as UInt64
                self.data      = data
                self.thumbnail = thumbnail
                self.file      = file
            } else {  // counter
                self.mid       = metadata?.mid!
                self.creator   = metadata?.creator!
                self.series    = metadata?.series!
                self.counter   = metadata?.counter! + 1 as UInt64
                self.data      = metadata?.data!
                self.thumbnail = metadata?.thumbnail!
                self.file      = metadata?.file!
            }
        }// Metadata init
    }// Metadata
/************************************************************************/
pub resource MetadataGenerator {
        priv var request  : {UInt64 : {Address: UFix64} }
        priv var metadata : {UInt64 : Metadata}
        
        init(metadata: Metadata) {
            pre{ DAAM.metadata[metadata.mid] == nil }   
            self.metadata = {}
            self.request = {}

            self.metadata.insert(key:metadata.mid, metadata)            
            DAAM.metadata.insert(key: metadata.mid, false)
            DAAM.copyright[metadata.mid] = CopyrightStatus.UNVERIFIED
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64  // Must be last
            
            log("Metadata Generatated ID: ".concat(metadata.mid.toString()) )
            emit DAAM.MetadataGeneratated(creator: self.metadata[metadata.mid]?.creator! , id: metadata.mid )
        }

        pub fun addMetadata(metadata: Metadata) {
            pre{
                metadata != nil
                DAAM.metadata[metadata.mid] == nil
            }
            
            self.metadata.insert(key:metadata.mid, metadata)
            DAAM.metadata.insert(key: metadata.mid, false)
            DAAM.copyright[metadata.mid] = CopyrightStatus.UNVERIFIED
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64  // Must be last
                        
            log("Metadata Generatated ID: ".concat(metadata.mid.toString()) )
            emit DAAM.MetadataGeneratated(creator: self.metadata[metadata.mid]?.creator!, id: metadata.mid )
        }

        pub fun removeMetadata(mid: UInt64)   {
            pre  { self.metadata[mid] != nil }
            self.metadata.remove(key: mid)
        }

        pub fun generateMetadata(mid: UInt64): @MetadataHolder {
            pre {
                self.metadata[mid] != nil : "Does not Exist"
                DAAM.metadata[mid] != nil : "Does not Exist"
            }            
            // Now Validated            
            log("Counter: ".concat(self.metadata[mid]?.counter!.toString()) )
            log("Series: ".concat(self.metadata[mid]?.series!.toString()) )

            let ref = &self as &MetadataGenerator  
            let royality = self.request[mid]!

            let metadata = Metadata(creator: self.metadata[mid]?.creator!, series: self.metadata[mid]?.series!, data: self.metadata[mid]?.data!,
                thumbnail: self.metadata[mid]?.thumbnail!, file: self.metadata[mid]?.file!, metadata: self.metadata[mid])
            let mh <- create MetadataHolder(metadata: metadata, royality: royality )

            if self.metadata[mid]?.counter == self.metadata[mid]?.series && self.metadata[mid]?.series != 0 as UInt64 {
                self.removeMetadata(mid: mid)
            }
            return <- mh         
        }

        priv fun addRequest(request: @RequestHolder) {
            self.request.insert(key: request.request.mid, request.request.royality)
            destroy request
        }
}
/************************************************************************/
    pub resource MetadataHolder {        
        access(contract) var metadata: Metadata
        access(contract) var royality: {Address : UFix64}

        init (metadata: Metadata, royality: {Address : UFix64}) {
            pre {
                metadata != nil
                royality != nil
            }
            self.metadata = metadata
            self.royality = royality
        }
        pub fun getMID(): UInt64 { return self.metadata.mid }
    }
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT {
        pub let id       : UInt64
        pub let metadata : Metadata
        pub let royality : {Address : UFix64}

        init(metadata: @MetadataHolder) {
            self.metadata = metadata.metadata
            self.royality = metadata.royality
            destroy metadata
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply
        }

        pub fun getCopyright(): CopyrightStatus {
            return DAAM.copyright[self.id]!
        }
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
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
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

        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre  { DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!" }
            post { DAAM.creators[creator] == status}
        }

        pub fun removeCreator(creator: Address) {
            pre  { DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!" }
            post { !DAAM.creators.containsKey(creator) }
        }

        pub fun removeAdmin(admin: Address)

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre  { DAAM.copyright.containsKey(mid): "This is an Invalid ID" }
            post { DAAM.copyright[mid] == copyright }
        }

        pub fun changMetadataStatus(mid: UInt64, status: Bool) {
            pre  { DAAM.copyright.containsKey(mid): "This is an Invalid ID" }
        }

        pub fun removeAdminInvite()
    }
/************************************************************************/
	pub resource Admin: Founder
    {
        priv var status: Bool
        priv var remove: [Address]

        init() {
            self.status = true
            self.remove = []
        }

        pub fun inviteAdmin(newAdmin: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
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
                log("Removed Admin")
                emit AdminRemoved(admin: admin)
            }
        }

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.copyright[mid] = copyright
            log("Token ID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        pub fun changMetadataStatus(mid: UInt64, status: Bool) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.metadata[mid] = status
        }
	}
/************************************************************************/
pub resource interface SeriesMinter {
     pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: @MetadataHolder)
}
/************************************************************************/
    pub resource Creator: SeriesMinter {

        pub fun newMetadataGenerator(metadata: Metadata): @MetadataGenerator {
            return <- create MetadataGenerator(metadata: metadata)
        }

        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: @MetadataHolder) {
            pre{
                DAAM.creators.containsKey(metadata.metadata.creator) : "You're no DAAM Creator!!"
                DAAM.creators[metadata.metadata.creator] == true     : "You Shitty Admin. This DAAM Creator's account is Frozen!!"
            } 
			let newNFT <- create NFT(metadata: <- metadata )
            let id = newNFT.id
			recipient.deposit(token: <- newNFT) // deposit it in the recipient's account using their reference            
            log("Minited NFT: ".concat(id.toString()))
            emit MintedNFT(id: id)            
		}	
    }
/************************************************************************/
    // public function that anyone can call to create a new empty collection
    pub fun answerAdminInvite(newAdmin: Address, submit: Bool): @Admin{Founder} {
        pre {
            DAAM.adminPending == newAdmin : "You got no DAAM Admin invite!!!. Get outta here!!"
            Profile.check(newAdmin)       : "You can't be a DAAM Admin without a Profile first! Go make one Fool!!"
        }
        DAAM.adminPending = nil
        if !submit { panic("Well, ... fuck you too!!!") }        
        log("Admin: ".concat(newAdmin.toString()).concat(" added to DAAM") )
        emit NewAdmin(admin: newAdmin)
        return <- create Admin()         
    }

    // TODO add interface restriction to collection
    pub fun answerCreatorInvite(newCreator: Address, submit: Bool): @Creator {
        pre {
            DAAM.creators.containsKey(newCreator) : "You got no DAAM Creator invite!!!. Get outta here!!"
            Profile.check(newCreator)  : "You can't be a DAAM Creator without a Profile first! Go make one Fool!!"
        }
        if !submit {
            DAAM.creators.remove(key: newCreator)
            panic("Maybe, another time")
        }      
        DAAM.creators[newCreator] = submit        
        log("Creator: ".concat(newCreator.toString()).concat(" added to DAAM") )
        emit NewCreator(creator: newCreator)
        return <- create Creator()
    }
    
    pub fun createEmptyCollection(): @Collection {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
        }
        return <- create Collection()
    }

    // DAAM Functions
	init() {
        // init Paths
        self.collectionPublicPath  = /public/DAAM_Collection
        self.collectionStoragePath = /storage/DAAM_Collection
        self.metadataStoragePath   = /storage/DAAM_SubmitNFT
        self.metadataPublicPath    = /public/DAAM_SubmitNFT
        self.adminPrivatePath      = /private/DAAM_Admin
        self.adminStoragePath      = /storage/DAAM_Admin
        self.creatorPrivatePath    = /private/DAAM_Creator
        self.creatorStoragePath    = /storage/DAAM_Creator

        //Custom variables should be contract arguments        
        self.adminPending = 0x01cf0e2f2f715450
        self.agency       = 0xeb179c27144f783c
        
        self.copyright = {}
        self.creators  = {}
        self.metadata  = {}
       
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.collectionCounterID = 0  // Incremental Serial Number for the Collections
        self.metadataCounterID   = 1  // Incremental Serial Number for the MetadataGenerator

        // Create a Minter resource and save it to storage
        let admin <- create Admin()
        self.account.save(<-admin, to: self.adminStoragePath)
        self.account.link<&Admin>(self.adminPrivatePath, target: self.adminStoragePath)

        emit ContractInitialized()
	}
}

