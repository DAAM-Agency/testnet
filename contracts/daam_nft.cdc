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
    pub event SubmitNFT()
    pub event MintedNFT(id: UInt64)
    pub event ChangedCopyright(tokenID: UInt64)

    pub let collectionPublicPath : PublicPath
    pub let collectionPrivatePath: PrivatePath
    pub let collectionStoragePath: StoragePath
    pub let adminPublicPath      : PublicPath
    pub let adminStoragePath     : StoragePath
    pub let adminPrivatePath     : PrivatePath
    pub let creatorStoragePath    : StoragePath
    pub let creatorPublicPath     : PublicPath
    // {Creator Profile address : Creator status; true being active}
    //access(contract) var creators: {Address: Bool}                   
    access(contract) var adminPending : Address?
    access(contract) var request: Request
    access(contract) var creators: {String: {Address: UFix64} } // {request as a string : Address List}
    pub var copyright: {UInt64: CopyrightStatus} // {NFT.id : CopyrightStatus}
    
    access(contract) var collectionCounterID: UInt64
    access(contract) var preArt: {Address: [Metadata]}

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
    pub let status          : String
    pub let changeroyality: String
    pub let reviewCopyright : String // ToDo

    init() {
        self.status            = "Status"
        self.changeroyality = "Change Royality"
        self.reviewCopyright  = "Review Copyright"
    }
}
/***********************************************************************/
    pub struct Metadata {  // Metadata for NFT,metadata initialization
        pub let creator   : Address   // Creator
        pub let data      : String    // JSON see metadata.json
        pub let thumbnail : String    // JSON see metadata.json
        pub let file      : String    // JSON see metadata.json
        
        init(creator: Address, metadata: String, thumbnail: String, file: String)
        {
            self.creator    = creator
            self.data       = metadata
            self.thumbnail  = thumbnail
            self.file       = file
        }// Metadata init        

        /* changeOwnerReceiver updates the capability for the sellers fungible token Vault
        pub fun changeOwnerReceiver(_ newOwnerCapability: Capability<&{FungibleToken.Receiver}>) {
            pre {
                newOwnerCapability.borrow() != nil: "Owner's Receiver Capability is invalid!"
            }
            self.ownerCapability = newOwnerCapability
        }

        // changeBeneficiaryReceiver updates the capability for the beneficiary of the cut of the sale
        pub fun changeBeneficiaryReceiver(_ newBeneficiaryCapability: Capability<&{FungibleToken.Receiver}>) {
            pre {
                newBeneficiaryCapability.borrow() != nil: "Beneficiary's Receiver Capability is invalid!" 
            }
            self.beneficiaryCapability = newBeneficiaryCapability
        }*/

    }// Metadata
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT {
        pub let id       : UInt64
        pub let metadata : Metadata
        pub var royality: {Address: UFix64}  // {royality address : percentage }
        //pub var series  : [UInt64]?  // TokenIDs of series

        init(metadata: Metadata) {
            self.metadata = metadata
            
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply

            self.royality = {DAAM.agency : 0.1}         // default setting
            self.royality[self.metadata.creator] = 0.2  // default setting
            //self.series = []
        }

        pub fun getCopyright(): CopyrightStatus {
            return DAAM.copyright[self.id]!
        }

        /*pub fun updateSeries(series: [UInt64]?) {
            pre{ self.series == nil : "Already Initialized!" }
            self.series = series
        }*/
    }
/************************************************************************/
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
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

        pub fun borrowDAAM(id: UInt64): &DAAM.NFT? {
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
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre {
                DAAM.creators[DAAM.request.status]![creator] == nil : "They're already a DAAM Creator!!!"
                Profile.check(creator)      : "You can't be a DAAM Creator without a Profile! Go make one Fool!!"
            }
        }

        pub fun changeRoyalityRequest(creator: Address, tokenID: UInt64, newPercentage: UFix64) {
            pre {
                DAAM.creators[DAAM.request.status]![creator] != nil : "They're no DAAM Creator!!!"
                DAAM.creators[DAAM.request.status]![creator] == 1.0 : "This DAAM Creator Account is frozen. Wake up Man, you're an Admin!!!"
                DAAM.creators[DAAM.request.changeroyality]![creator] == nil : "There already is a Request. Only 1 at a time...for now"
            }
        }

        pub fun removeRequest(request: String, creator: Address) {
            pre{
                DAAM.creators[request]![creator] != nil : "They're no DAAM Request!!!"
            }
        }

        pub fun freezeCreator(creator: Address) {
            pre{
                DAAM.creators[DAAM.request.status]![creator] != nil : "They're no DAAM Creator!!!"
            }
        }

        pub fun removeCreator(creator: Address) {
            pre{
                DAAM.creators[DAAM.request.status]![creator] != nil : "They're no DAAM Creator!!!"
            }
        }

        pub fun removeAdmin(admin: Address)

        pub fun changeCopyright(id: UInt64, copyright: CopyrightStatus)
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
            emit AdminInvited(admin: newAdmin)
            log("Sent Admin Invation: ".concat(newAdmin.toString()) )            
        }

        pub fun inviteCreator(_ creator: Address) {  // Admin add a new creator
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            let ref = &DAAM.creators[DAAM.request.status] as &{Address: UFix64}
            ref[creator] = 0.0 // When  status is 0.0 consider active but suspended.
            // Can also be used as a security level
            // TODO Add time limit
            emit CreatorInvited(creator: creator)
            log("Sent Creator Invation: ".concat(creator.toString()) )            
        }
        
        pub fun changeRoyalityRequest(creator: Address, tokenID: UInt64, newPercentage: UFix64) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }        
            let ref = &DAAM.creators[DAAM.request.changeroyality] as &{Address: UFix64}
            let data = UFix64(tokenID) + newPercentage
            ref[creator] = data
            log("Changed Royality to ".concat(newPercentage.toString()) )
            //emit CommisionChanged(newPercent: newPercent, seller: self.owner?.address)
        }

        pub fun removeRequest(request: String, creator: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            let ref = &DAAM.creators[request] as &{Address: UFix64}
            ref.remove(key: creator)
        }

        pub fun freezeCreator(creator: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            let ref = &DAAM.creators[DAAM.request.status] as &{Address: UFix64}
            ref[creator] = 0.0 as UFix64? // represents False
        }

        pub fun removeCreator(creator: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            var ref = &DAAM.creators[DAAM.request.status] as &{Address: UFix64}
            ref.remove(key: creator)
            ref = &DAAM.creators[DAAM.request.changeroyality] as &{Address: UFix64}
            ref.remove(key: creator)
            DAAM.preArt.remove(key: creator)
        }

        pub fun removeAdmin(admin: Address) {
            pre{
                self.status : "You're no longer a DAAM Admin!!"
                !self.remove.contains(admin) : "You already did"
            }
            self.remove.append(admin)
            if self.remove.length >= 2 { self.status = false }
        }

        pub fun changeCopyright(id: UInt64, copyright: CopyrightStatus) {
            DAAM.copyright[id] = copyright
            emit ChangedCopyright(tokenID: id)
            log("Token ID: ".concat(id.toString()).concat("Copyright Changed") )
        }
	}
/************************************************************************/
    pub resource Creator {
        pub fun submitNFT(creator: Address, metadata: Metadata) {
            if DAAM.preArt[creator] == nil {
                DAAM.preArt[creator] = [metadata]
            } else {
                 DAAM.preArt[creator]!.append(metadata)
            }
            emit SubmitNFT()            
            log("NFT Proposed")
        }

        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, creator: Address, elm: Int, copyrightStatus: CopyrightStatus) {
            pre{
                elm > -1                          : "Wrong Selection"
                //elm % 2 as Int == 1 as Int        : "Wrong Selection"
                //copyrightStatus == CopyrightStatus.VERIFIED : "Must Verify First" TODO
                DAAM.preArt[creator] != nil : "Did you submit a DAAM NFT...?!?"                
            }

            let records = &DAAM.preArt[creator] as! &[Metadata]
            let metadata = records[elm]
			let newNFT <- create NFT(metadata: metadata) // TODO Get metadata from preArt
            let id = newNFT.id

			recipient.deposit(token: <- newNFT) // deposit it in the recipient's account using their reference
            DAAM.preArt[creator]?.remove(at: elm)!

            DAAM.copyright[id] = copyrightStatus

            emit MintedNFT(id: id)
            log("Minited NFT: ".concat(id.toString()))
		}
	

        pub fun answerRequest(creator: Address, nft: &NFT, answer: Bool, request: String) {
            pre {
                DAAM.creators[request] != nil : "That isn't even a DAAM request!!"
                DAAM.creators[DAAM.request.status]![creator] != nil : "You got no DAAM Creator invite!!!. Get outta here!!"
                DAAM.creators[DAAM.request.status]![creator] != 0.0 : "You're DAAM Creator account is frozen!!"
                Profile.check(creator)        : "You can't be a DAAM Creator without a Profile first! Go make one Fool!!"
                DAAM.creators[request]![creator] != nil  : "That Request has not been made"
            }        

            if answer {
                let data = DAAM.creators[request]![creator]!
                switch request {
                    case DAAM.request.changeroyality:                    
                        let newPercentage = data - UFix64(UInt(data))
                        if nft.id != UInt64(data) { panic("Wrong Token") }
                        nft.royality[creator] = newPercentage
                        log(request.concat(" ".concat(newPercentage.toString())) )
                }// end switch         
            } else {
                log("Change Royality Refused")
            }
            DAAM.creators[request]!.remove(key: creator)
        }
    

        /*pub fun updateSeries(creator: Address, series: [UInt64]) {
            var collection = &DAAM.collection[creator] as &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}
            let tokenIDs = collection.getIDs()
            for id in series {
                if !tokenIDs.contains(id) { return }
            }
            var nft <- collection.withdraw(withdrawID: 0) as! @DAAM.NFT
            (nft.series == nil) ?  nft.updateSeries(series: series) : log("Already initialized")
            collection.deposit(token: <- nft)
        }*/
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
        emit NewAdmin(admin: newAdmin)
        log("Admin: ".concat(newAdmin.toString()).concat(" added to DAAM") )
        return <- create Admin()         
    }

    // TODO add interface restriction to collection
    pub fun answerCreatorInvite(newCreator: Address, submit: Bool): @Creator {
        pre {
            DAAM.creators[DAAM.request.status]![newCreator] != nil : "You got no DAAM Creator invite!!!. Get outta here!!"
            Profile.check(newCreator)       : "You can't be a DAAM Creator without a Profile first! Go make one Fool!!"
        }
        if submit {
            let ref = &DAAM.creators[DAAM.request.status] as &{Address: UFix64}
            ref[newCreator] = 1.0 as UFix64? // represents True
            emit NewCreator(creator: newCreator)
            log("Creator: ".concat(newCreator.toString()).concat(" added to DAAM") )
            return <- create Creator()
        }
        DAAM.creators[DAAM.request.status]!.remove(key: newCreator)
        panic("Well, ... fuck you too!!!")
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
        self.collectionPrivatePath = /private/DAAM_Collection
        self.collectionStoragePath = /storage/DAAM_Collection
        self.adminPublicPath       = /public/DAAM_Admin
        self.adminPrivatePath      = /private/DAAM_Admin
        self.adminStoragePath      = /storage/DAAM_Admin
        self.creatorPublicPath      = /public/DAAM_Creator
        self.creatorStoragePath     = /storage/DAAM_Creator

        //Custom variables should be contract arguments        
        self.adminPending = 0x01cf0e2f2f715450
        self.agency       = 0xeb179c27144f783c

        self.creators  = {}
        self.request = Request()
        self.creators[self.request.status] = {}
        self.creators[self.request.changeroyality] = {}
        self.copyright  = {}

        self.preArt = {}
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.collectionCounterID = 0  // Incremental Serial Number for the Collections               

        // Create a Minter resource and save it to storage
        let admin <- create Admin()
        self.account.save(<-admin, to: self.adminStoragePath)
        self.account.link<&Admin>(self.adminPublicPath, target: self.adminStoragePath)

        emit ContractInitialized()
	}
}

