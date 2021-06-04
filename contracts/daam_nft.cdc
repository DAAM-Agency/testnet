// daam_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken    from 0x9a0766d93b6608b7
import Profile          from 0xba1132bc08f82fe2
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
    pub event RoyalityChangeRequest(newPercent: UFix64, creator: Address)
    pub event ChangeCreatorStatus(creator: Address, status: Bool)
    pub event CreatorRemoved(creator: Address)
    pub event AdminRemoved(admin: Address)
    pub event RequestAnswered(creator: Address, answer: Bool, request: UInt8)

    pub let collectionPublicPath : PublicPath
    pub let collectionStoragePath: StoragePath
    pub let metadataPublicPath   : PublicPath
    pub let metadataStoragePath  : StoragePath
    pub let adminStoragePath     : StoragePath
    pub let adminPrivatePath     : PrivatePath
    pub let creatorStoragePath   : StoragePath
    pub let creatorPrivatePath   : PrivatePath
                 
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
        pub let mid       : UInt64
        pub let creator   : Address  // Creator
        pub let series    : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let counter   : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let data      : String   // JSON see metadata.json
        pub let thumbnail : String   // JSON see metadata.json
        pub let file      : String   // JSON see metadata.json
        
        init(creator: Address, series: UInt64, counter: UInt64, data: String, thumbnail: String, file: String) {
                self.mid       = DAAM.metadataCounterID
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
        priv var counter  : [UInt64] 
        priv var metadata : [Metadata]
        
        init(metadata: Metadata) {
            pre{ DAAM.metadata[metadata.mid] == nil }
            self.counter  = [0 as UInt64]
            self.metadata = [metadata]
            DAAM.metadata.insert(key: self.metadata[0].mid, false)
            DAAM.copyright[self.metadata[0].mid] = CopyrightStatus.UNVERIFIED
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64

            log("Metadata Generatated".concat(self.metadata[0].mid.toString()) )
            emit DAAM.MetadataGeneratated(creator: metadata.creator, id: self.metadata[0].mid )
        }

        pub fun addMetadata(metadata: Metadata) {
            pre{ DAAM.metadata[metadata.mid] == nil } 
            self.counter.append(0 as UInt64)    
            self.metadata.append(metadata)
            let elm = self.metadata.length-1
            DAAM.metadata.insert(key: self.metadata[elm].mid, false)            
            DAAM.copyright[self.metadata[elm].mid] = CopyrightStatus.UNVERIFIED
            DAAM.metadataCounterID = DAAM.metadataCounterID + 1 as UInt64

            log("Metadata Generatated".concat(self.metadata[elm].mid.toString()) )
            emit DAAM.MetadataGeneratated(creator: metadata.creator, id: self.metadata[elm].mid )
        }

        pub fun removeMetadata(_ elm: UInt16)   {
            pre  { self.metadata[elm] != nil }
            self.metadata.remove(at: elm)
            self.counter.remove(at: elm)
        }

        pub fun generateMetadata(mid: UInt64): @MetadataHolder {
            let elm = self.getElmFromMID(mid: mid)
            

            // Do check, fake pre {}
            if DAAM.metadata[self.metadata[elm].mid] == nil  { panic("Does not Exist") }
            self.counter[elm] = self.counter[elm] + 1 as UInt64
            if self.counter[elm] > self.metadata[elm].series { panic("Counter is greater then Series") }

            // Now Validated
            
            log("Counter: ".concat(self.counter[elm].toString()) )
            log("Series: ".concat(self.metadata[elm].series.toString()) )
            let ref = &self as &MetadataGenerator
            
            let metadata = Metadata(creator: self.metadata[elm].creator, series: self.metadata[elm].series,
                counter: self.counter[elm], data: self.metadata[elm].data, thumbnail: self.metadata[elm].thumbnail,
                file: self.metadata[elm].file)
            let mh <- create MetadataHolder(metadata: metadata)

            if self.metadata[elm].counter == self.metadata[elm].series && self.metadata[elm].series != 0 as UInt64 {
                self.removeMetadata(elm)
            }
            return <- mh         
        }

        priv fun getElmFromMID(mid: UInt64): UInt16 {
            var counter = 0 as UInt16
            log(self.metadata.length.toString())
            for m in self.metadata {
                if m.mid == mid { return counter}
                counter = counter + 1 as UInt16
            }
            return counter - 1 as UInt16
        }
}
/************************************************************************/
    pub resource MetadataHolder {        
        access(contract) var metadata: Metadata
        init (metadata: Metadata) { self.metadata = metadata }
        pub fun getID(): UInt64 { return self.metadata.mid }
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
                tokenID <= DAAM.totalSupply            : "Invalid ID"
                DAAM.creators.containsKey(creator)     : "They're no DAAM Creator!!!"
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

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre  { DAAM.copyright.containsKey(mid): "This is an Invalid ID" }
            post { DAAM.copyright[mid] == copyright }
        }

        pub fun changMetadataStatus(mid: UInt64, status: Bool) {
            pre  { DAAM.copyright.containsKey(mid): "This is an Invalid ID" }
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
            ref.changeRoyality[tokenID] = newPercentage
            log("Changed Royality to ".concat(newPercentage.toString()) )
            emit RoyalityChangeRequest(newPercent: newPercentage, creator: creator)
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
                DAAM.creators[metadata.metadata.creator]!.status     : "You Shitty Admin. This DAAM Creator's account is Frozen!!"
            } 
			let newNFT <- create NFT(metadata: <- metadata )
            let id = newNFT.id
			recipient.deposit(token: <- newNFT) // deposit it in the recipient's account using their reference            
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
                        let newPercentage = getRequest.changeRoyality[nft.id]                    
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

