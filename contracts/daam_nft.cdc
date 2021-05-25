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
    pub event NewArtist(artist: Address)
    pub event AdminInvited(admin  : Address)
    pub event ArtistInvited(artist: Address)
    pub event SubmitNFT()
    pub event MintedNFT(id: UInt64)
    pub event SetCopyright(tokenID: UInt64)

    pub let collectionPublicPath : PublicPath
    pub let collectionPrivatePath: PrivatePath
    pub let collectionStoragePath: StoragePath
    pub let adminPublicPath      : PublicPath
    pub let adminStoragePath     : StoragePath
    pub let adminPrivatePath     : PrivatePath
    pub let artistStoragePath    : StoragePath
    pub let artistPrivatePath    : PrivatePath
    // {Artist Profile address : Artist status; true being active}
    //access(contract) var artists: {Address: Bool}                   
    access(contract) var adminPending : Address?
    access(contract) var request: Request
    access(contract) var artists: {String: {Address: UFix64} } // {request as a string : Address List}
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
    }
/***********************************************************************/
pub struct Request {
    pub let status: String
    pub let changeCommission: String

    init() {
        self.status = "Status"
        self.changeCommission = "Change Commission"
    }
}
/***********************************************************************/
    pub struct Metadata {  // Metadata for NFT,metadata initialization
        pub let creator   : Address   // Artist
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
        pub var commission: {Address: UFix64}  // {commission address : percentage }
        //pub var series  : [UInt64]?  // TokenIDs of series

        init(metadata: Metadata) {
            self.metadata = metadata
            
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply

            self.commission = {DAAM.agency : 0.1}         // default setting
            self.commission[self.metadata.creator] = 0.2  // default setting
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

        pub fun inviteArtist(_ artist: Address) {  // Admin add a new artist
            pre {
                DAAM.artists[DAAM.request.status]![artist] == nil : "They're already a DAAM Artist!!!"
                Profile.check(artist)      : "You can't be a DAAM Artist without a Profile! Go make one Fool!!"
            }
        }

        pub fun changeCommissionRequest(artist: Address, tokenID: UInt64, newPercentage: UFix64) {
            pre {
                DAAM.artists[DAAM.request.status]![artist] != nil : "They're no DAAM Artist!!!"
                DAAM.artists[DAAM.request.status]![artist] == 1.0 : "This DAAM Artist Account is frozen. Wake up Man, you're an Admin!!!"
                DAAM.artists[DAAM.request.changeCommission]![artist] == nil : "There already is a Request. Only 1 at a time...for now"
            }
        }

        pub fun removeRequest(request: String, artist: Address) {
            pre{
                DAAM.artists[request]![artist] != nil : "They're no DAAM Request!!!"
            }
        }

        pub fun freezeArtist(artist: Address) {
            pre{
                DAAM.artists[DAAM.request.status]![artist] != nil : "They're no DAAM Artist!!!"
            }
        }

        pub fun removeArtist(artist: Address) {
            pre{
                DAAM.artists[DAAM.request.status]![artist] != nil : "They're no DAAM Artist!!!"
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

        pub fun inviteArtist(_ artist: Address) {  // Admin add a new artist
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            let ref = &DAAM.artists[DAAM.request.status] as &{Address: UFix64}
            ref[artist] = 0.0 // When  status is 0.0 consider active but suspended.
            // Can also be used as a security level
            // TODO Add time limit
            emit ArtistInvited(artist: artist)
            log("Sent Artist Invation: ".concat(artist.toString()) )            
        }
        
        pub fun changeCommissionRequest(artist: Address, tokenID: UInt64, newPercentage: UFix64) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }        
            let ref = &DAAM.artists[DAAM.request.changeCommission] as &{Address: UFix64}
            let data = UFix64(tokenID) + newPercentage
            ref[artist] = data
            log("Changed Commission to ".concat(newPercentage.toString()) )
            //emit CommisionChanged(newPercent: newPercent, seller: self.owner?.address)
        }

        pub fun removeRequest(request: String, artist: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            let ref = &DAAM.artists[request] as &{Address: UFix64}
            ref.remove(key: artist)
        }

        pub fun freezeArtist(artist: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            let ref = &DAAM.artists[DAAM.request.status] as &{Address: UFix64}
            ref[artist] = 0.0 as UFix64? // represents False
        }

        pub fun removeArtist(artist: Address) {
            pre{ self.status : "You're no longer a DAAM Admin!!" }
            var ref = &DAAM.artists[DAAM.request.status] as &{Address: UFix64}
            ref.remove(key: artist)
            ref = &DAAM.artists[DAAM.request.changeCommission] as &{Address: UFix64}
            ref.remove(key: artist)
            DAAM.preArt.remove(key: artist)
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
            emit SetCopyright(tokenID: id)
            log("Token ID: ".concat(id.toString()).concat("Copyright Changed") )
        }
	}
/************************************************************************/
    pub resource Artist {
        pub fun submitNFT(artist: Address, metadata: Metadata) {
            DAAM.preArt[artist]?.append(metadata)!
            emit SubmitNFT()
            log("NFT Proposed")
        }

        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: Metadata) {
			let newNFT <-! create NFT(metadata: metadata)
            let id = newNFT.id
			recipient.deposit(token: <-newNFT)  // deposit it in the recipient's account using their reference
            emit MintedNFT(id: id)
            log("Minited NFT: ".concat(id.toString()))
		}
	

        pub fun answerRequest(artist: Address, nft: &NFT, answer: Bool, request: String) {
            pre {
                DAAM.artists[request] != nil : "That isn't even a DAAM request!!"
                DAAM.artists[DAAM.request.status]![artist] != nil : "You got no DAAM Artist invite!!!. Get outta here!!"
                DAAM.artists[DAAM.request.status]![artist] != 0.0 : "You're DAAM Artist account is frozen!!"
                Profile.check(artist)        : "You can't be a DAAM Artist without a Profile first! Go make one Fool!!"
                DAAM.artists[request]![artist] != nil  : "That Request has not been made"
            }        

            if answer {
                let data = DAAM.artists[request]![artist]!
                switch request {
                    case DAAM.request.changeCommission:                    
                        let newPercentage = data - UFix64(UInt(data))
                        if nft.id != UInt64(data) { panic("Wrong Token") }
                        nft.commission[artist] = newPercentage
                        log(request.concat(" ".concat(newPercentage.toString())) )
                }// end switch         
            } else {
                log("Change Commission Refused")
            }
            DAAM.artists[request]!.remove(key: artist)
        }
    

        /*pub fun updateSeries(artist: Address, series: [UInt64]) {
            var collection = &DAAM.collection[artist] as &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}
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
    pub fun answerArtistInvite(newArtist: Address, submit: Bool): @Artist {
        pre {
            DAAM.artists[DAAM.request.status]![newArtist] != nil : "You got no DAAM Artist invite!!!. Get outta here!!"
            Profile.check(newArtist)       : "You can't be a DAAM Artist without a Profile first! Go make one Fool!!"
        }
        if submit {
            let ref = &DAAM.artists[DAAM.request.status] as &{Address: UFix64}
            ref[newArtist] = 1.0 as UFix64? // represents True
            emit NewArtist(artist: newArtist)
            log("Artist: ".concat(newArtist.toString()).concat(" added to DAAM") )
            return <- create Artist()
        }
        DAAM.artists[DAAM.request.status]!.remove(key: newArtist)
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
        self.artistPrivatePath     = /private/DAAM_Artist
        self.artistStoragePath     = /storage/DAAM_Artist

        //Custom variables should be contract arguments        
        self.adminPending = 0x01cf0e2f2f715450
        self.agency       = 0xeb179c27144f783c

        self.artists  = {}
        self.request = Request()
        self.artists[self.request.status] = {}
        self.artists[self.request.changeCommission] = {}
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

