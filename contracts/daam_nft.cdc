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
    pub event ChangedCopyright(tokenID: UInt64)
    pub event RoyalityChanged(newPercent: UFix64, creator: Address)
    pub event ChangeCreatorStatus(creator: Address, status: Bool)
    pub event CreatorRemoved(creator: Address)
    pub event AdminRemoved(admin: Address)
    pub event RequestAnswered(creator: Address, answer: Bool, request: UInt8)

    pub let collectionPublicPath : PublicPath
    pub let collectionStoragePath: StoragePath
    pub let metadataPrivatePath  : PrivatePath
    pub let metadataStoragePath  : StoragePath
    pub let adminPublicPath      : PublicPath
    pub let adminStoragePath     : StoragePath
    pub let adminPrivatePath     : PrivatePath
    pub let creatorStoragePath   : StoragePath
    pub let creatorPublicPath    : PublicPath
                 
    access(contract) var adminPending : Address?
    access(contract) var creators: {Address: Request} // {request as a string : Address List}
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
pub struct Request {
    pub var status         : Bool
    pub var changeRoyality : {UInt64 : UFix64}  // {id : 0.2 new royality}
    //pub let reviewCopyright: Bool // ToDo

    init() {  // Any additions, make sure to update answerRequest
        self.status         = false
        self.changeRoyality = {}
        //self.reviewCopyright = "Review Copyright"// ToDo v2
    }

    pub fun setStatus(status: Bool) {self.status = status}
}
/***********************************************************************/
    pub struct Metadata {  // Metadata for NFT,metadata initialization
        pub let creator   : Address  // Creator
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let data      : String   // JSON see metadata.json
        pub let thumbnail : String   // JSON see metadata.json
        pub let file      : String   // JSON see metadata.json
        
        init(creator: Address, series: UInt64, counter: UInt64, data: String, thumbnail: String, file: String) {            
                self.creator   = creator
                self.series    = series
                self.counter   = counter
                self.data      = data
                self.thumbnail = thumbnail
                self.file      = file
        }// Metadata init
    }// Metadata
/************************************************************************/
pub resource MetadataGenerator {
        pub var id       : [UInt64]
        pub var status   : [Bool]        
        pub var metadata : [Metadata]
        
        init(metadata: Metadata) {
            self.id       = []
            self.status   = []           
            self.metadata = []
            self.addMetadata(metadata: metadata)
        }

        pub fun addMetadata(metadata: Metadata) {
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64
            self.id.append(DAAM.metadataCounterID)
            self.status.append(true)           
            self.metadata.append(metadata)
            DAAM.metadata.insert(key: DAAM.metadataCounterID, false)

            log("Metadata Generatated: ".concat(DAAM.metadataCounterID.toString()) )
            emit DAAM.MetadataGeneratated(creator: metadata.creator, id: DAAM.metadataCounterID)
        }

        pub fun removeMetadata(_ elm: UInt16)   {
            self.metadata.remove(at: elm)
            self.id.remove(at: elm)
            self.status.remove(at: elm)
        }

        pub fun generateMetadata(_ elm: UInt16): @MetadataHolder {
            pre {
                DAAM.metadata[self.id[elm]] == true : "Missing Approval"
                self.status[elm]
                self.metadata[elm].counter <= self.metadata[elm].series || self.metadata[elm].series == 0 as UInt64 // 0 = unlimited
            }

            let counter = self.metadata[elm].counter + 1 as UInt64
            let ref = &self as &MetadataGenerator

            let metadata = Metadata(creator: self.metadata[elm].creator, series: self.metadata[elm].series, counter: counter,
                data: self.metadata[elm].data, thumbnail: self.metadata[elm].thumbnail, file: self.metadata[elm].file)
            let mh <- create MetadataHolder(metadata: metadata)

            if self.metadata[elm].counter == self.metadata[elm].series && self.metadata[elm].series != 0 as UInt64 {
                self.removeMetadata(elm)
            }
            return <- mh         
        }

        pub fun isSeries(_ elm: UInt16): Bool { return self.metadata[elm].series != 1 as UInt64 } // make inline TODO
}
/************************************************************************/
    pub resource MetadataHolder {        
        access(contract) var metadata: Metadata
        init (metadata: Metadata) { self.metadata = metadata }
    }
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT {
        pub let id       : UInt64
        pub let metadata : Metadata
        pub var royality : {Address : UFix64}  // {royality address : percentage }

        init(metadata: @MetadataHolder) {
            self.metadata = metadata.metadata
            destroy metadata

            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply

            self.royality = {DAAM.agency : 0.1}         // default setting
            self.royality[self.metadata.creator] = 0.2  // default setting
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
            post { DAAM.creators[creator]?.status == false }
        }

        pub fun changeRoyalityRequest(creator: Address, tokenID: UInt64, newPercentage: UFix64) {
            pre {
                DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!"
                DAAM.creators[creator]?.status == true : "This DAAM Creator Account is frozen. Wake the Fuck Man, you're an DAAM Admin!!!"
                DAAM.creators[creator]?.changeRoyality != nil : "There already is a Request. Only 1 at a time...for now"
            }
            post { DAAM.creators[creator]!.changeRoyality[tokenID]! == newPercentage }
        }

        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre  { DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!" }
            post { DAAM.creators[creator]?.status == status}
        }

        pub fun removeCreator(creator: Address) {
            pre  { DAAM.creators.containsKey(creator) : "They're no DAAM Creator!!!" }
            post { !DAAM.creators.containsKey(creator) }
        }

        pub fun removeAdmin(admin: Address)

        pub fun changeCopyright(id: UInt64, copyright: CopyrightStatus) {
            pre  { DAAM.copyright.containsKey(id): "This is an Invalid ID" }
            post { DAAM.copyright[id] == copyright }
        }

        pub fun changMetadataStatus(id: UInt64, status: Bool) {
            pre  { DAAM.metadata[id] != nil : "Invalid ID" }
        }
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
            // TODO Add time limit
            log("Sent Admin Invation: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.creators.insert(key: creator, Request() ) 
            // TODO Add time limit            
            log("Sent Creator Invation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)         
        }
        
        pub fun changeRoyalityRequest(creator: Address, tokenID: UInt64, newPercentage: UFix64) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            var ref = &DAAM.creators[creator] as &Request
            // TODO Confirm tokenID
            ref.changeRoyality[tokenID] = newPercentage
            log("Changed Royality to ".concat(newPercentage.toString()) )
            emit RoyalityChanged(newPercent: newPercentage, creator: creator)
        }

        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre{ self.status : "This account is already frozen" }
            let ref = &DAAM.creators[creator] as &Request
            ref.setStatus(status: status)
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

        pub fun changeCopyright(id: UInt64, copyright: CopyrightStatus) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.copyright[id] = copyright
            log("Token ID: ".concat(id.toString()) )
            emit ChangedCopyright(tokenID: id)            
        }

        pub fun changMetadataStatus(id: UInt64, status: Bool) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            DAAM.metadata[id] = status
        }
	}
/************************************************************************/
    pub resource Creator {
        pub fun newMetadataGenerator(metadata: Metadata): @MetadataGenerator {
            return <- create MetadataGenerator(metadata: metadata)
        }

        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: @MetadataHolder) {
            pre{
                DAAM.creators.containsKey(metadata.metadata.creator) : "You're no DAAM Creator!!"
                DAAM.creators[metadata.metadata.creator]!.status     : "You Shitty Admin. This DAAM Creator's account is Frozen!!"
            } 
			let newNFT <- create NFT(metadata: <- metadata )
            let id = newNFT.id
			recipient.deposit(token: <- newNFT) // deposit it in the recipient's account using their reference            
            DAAM.copyright[id] = CopyrightStatus.UNVERIFIED
            log("Minited NFT: ".concat(id.toString()))
            emit MintedNFT(id: id)            
		}	

        pub fun answerRequest(creator: Address, nft: &NFT, answer: Bool, request: UInt8) {
            pre {
                DAAM.creators.containsKey(creator) : "You're no DAAM Creator!!"
                DAAM.creators[creator]!.status     : "Pay Attenction!! This DAAM Creator account is frozen. You suck at your Job!!"
                Profile.check(creator)             : "You can't be a DAAM Creator without a Profile first! Go make one Fool!!"
                request < 1 as UInt8               : "No such DAAM request"
            }
            let getRequest = &DAAM.creators[creator] as &Request

            if answer {                
                switch request {
                    case 0 as UInt8:  // Change Royality                
                        let newPercentage = getRequest.changeRoyality[nft.id]!                     
                        nft.royality[creator] = newPercentage
                        log("Request: Change Royality: Accepted")
                }// end switch         
            } else {
                log("Request: Change Royality: Refused")
            }
            getRequest.changeRoyality.remove(key: nft.id)
            emit RequestAnswered(creator: creator, answer: answer, request: request)
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
        var ref = &DAAM.creators[newCreator] as &Request
        ref.setStatus(status: submit)

        if submit {           
            log("Creator: ".concat(newCreator.toString()).concat(" added to DAAM") )
            emit NewCreator(creator: newCreator)
            return <- create Creator()
        } else {
            DAAM.creators.remove(key: newCreator)
            return nil!
        }
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
        self.metadataPrivatePath   = /private/DAAM_SubmitNFT
        self.adminPublicPath       = /public/DAAM_Admin
        self.adminPrivatePath      = /private/DAAM_Admin
        self.adminStoragePath      = /storage/DAAM_Admin
        self.creatorPublicPath     = /public/DAAM_Creator
        self.creatorStoragePath    = /storage/DAAM_Creator

        //Custom variables should be contract arguments        
        self.adminPending = 0x01cf0e2f2f715450
        self.agency       = 0xeb179c27144f783c
        
        self.copyright = {}
        self.creators  = {}
        self.metadata  = {}
       
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.collectionCounterID = 0  // Incremental Serial Number for the Collections
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        // Create a Minter resource and save it to storage
        let admin <- create Admin()
        self.account.save(<-admin, to: self.adminStoragePath)
        self.account.link<&Admin>(self.adminPublicPath, target: self.adminStoragePath)

        emit ContractInitialized()
	}
}

