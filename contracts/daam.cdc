// daam.cdc

import NonFungibleToken from 0x120e725050340cab
import Profile from 0x192440c99cb17282

pub contract DAAM: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id : UInt64,   to: Address?)
    pub event NewAdmin(admin  : Address)
    pub event NewArtist(artist: Address)
    pub event AdminInvited(admin  : Address)
    pub event ArtistInvited(artist: Address)
    pub event MintedNFT(id: UInt64)

    pub let collectionPublicPath : PublicPath
    pub let collectionStoragePath: StoragePath
    pub let adminPublicPath      : PublicPath
    pub let adminStoragePath     : StoragePath
    pub let adminPrivatePath     : PrivatePath
    pub let artistStoragePath    : StoragePath
    pub let artistPrivatePath    : PrivatePath
    // {Artist Profile address : Artist status; true being active}
    access(contract) var artist: {Address: Bool}
    pub var adminPending : Address?
    
    pub var collectionCounterID: UInt64
    pub var collection: @Collection

/************************************************************************/
    pub struct Metadata {  // Metadata for NFT,metadata initialization
        // {String:String} repesents {Format:File} ; a Metadata standard
        pub let title     : String            // Title                   
        pub let creator   : Address           // Artist
        pub let series    : [UInt64]          // If, Part of which series  TODO FIX UPGRADE to NFT
        pub let isPhysical: Bool              // Does this have a physical counter-part        
        pub let agency    : String            // Sold from which Gallery or Online // UPGRADE to NFT 
        pub let about     : {String: String}  // About NFT, Blurb or website 
        pub let thumbnail : {String: String}  // Thumbnail
        pub let file      : {String: String}  // File, Actual Content                     

        init(title:String, creator:Address, series:[UInt64], physical:Bool, agency:String,
        about:{String: String}, thumbnail:{String: String}, file:{String: String})
        {
            self.title = title
            self.creator = creator
            self.series = series
            self.isPhysical = physical
            self.agency = agency
            self.about = about
            self.thumbnail = thumbnail
            self.file = file
        }// Metadata init
    }// Metadata
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub var metadata: Metadata

        init(metadata: Metadata) {
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply
            self.metadata = metadata
        }
    }
/************************************************************************/
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens. NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () { self.ownedNFTs <- {} }

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

        destroy() { destroy self.ownedNFTs }
    }
/************************************************************************/
    pub resource interface Founder {
        pub fun inviteAdmin(newAdmin: Address) {
            pre{
                DAAM.adminPending == nil : "Admin already pending. Waiting on confirmation."
                Profile.check(newAdmin)  : "You can't add D.A.A.M Admin without a Profile! Tell'em to make one first!!"
            }
        }

        pub fun inviteArtist(_ artist: Address) {  // Admin add a new artist
            pre {
                DAAM.artist[artist] == nil : "They're already a D.A.A.M Artist!!!"
                Profile.check(artist)      : "You can't be a D.A.A.M Artist without a Profile! Go make one Fool!!"
            }
        }
    }
/************************************************************************/
    pub resource interface InvitedAdmin {
        pub fun answerAdminInvite(_ newAdmin: Address,_ submit: Bool): @Admin{Founder} {
            pre {
                DAAM.adminPending == newAdmin : "You got no D.A.A.M Admin invite!!!. Get outta here!!"
                Profile.check(newAdmin)       : "You can't be a D.A.A.M Admin without a Profile first! Go make one Fool!!"
                submit == true                : "Well, ... fuck you too!!!"
            }      
        }        
    }
/************************************************************************/
    pub resource interface InvitedArtist {
        pub fun answerArtistInvite(_ artist: Address,_ submit: Bool): @Artist {
            pre {
                DAAM.artist[artist] != nil : "You got no D.A.A.M Artist invite!!!. Get outta here!!"
                Profile.check(artist)      : "You can't be a D.A.A.M Artist without a Profile first! Go make one Fool!!"
                submit == true             : "OK ?!? Then why the fuck did you even bother ?!?"
            }
        }
    }
/************************************************************************/
	pub resource Admin: Founder, InvitedAdmin, InvitedArtist
    {
        pub fun inviteAdmin(newAdmin: Address) {
            emit AdminInvited(admin: newAdmin)
            log("New Admin invitation")  
            DAAM.adminPending = newAdmin
            // TODO Add time limit
        }

        pub fun inviteArtist(_ artist: Address) {  // Admin add a new artist
            emit ArtistInvited(artist: artist)
            log("New Artist added to D.A.A.M")        
            DAAM.artist[artist] = false
            // TODO Add time limit
        }

        pub fun answerAdminInvite(_ newAdmin: Address,_ submit: Bool): @Admin {
            pre {
                DAAM.adminPending == newAdmin : "You got no D.A.A.M Admin invite!!!. Get outta here!!"
                Profile.check(newAdmin)       : "You can't be a D.A.A.M Admin without a Profile first! Go make one Fool!!"
                submit == true                : "Well, ... fuck you too!!!"
            }
            DAAM.adminPending = nil
            emit NewAdmin(admin: newAdmin)
            log("New Admin added to D.A.A.M")
            return <- create Admin()         
        }

        pub fun answerArtistInvite(_ artist: Address,_ submit: Bool): @Artist {
            pre {
                DAAM.artist[artist] != nil : "You got no D.A.A.M Artist invite!!!. Get outta here!!"
                Profile.check(artist)      : "You can't be a D.A.A.M Artist without a Profile first! Go make one Fool!!"
                submit == true             : "OK ?!? Then why the fuck did you even bother ?!?"
            }
            DAAM.artist[artist] = true
            emit NewArtist(artist: artist)
            log("New Artist added to D.A.A.M")
            return <- create Artist()
        }

        // ToDo self destruct Remove Admin is missing
	}
/************************************************************************/
    pub resource Artist {
        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
		pub fun mintNFT(metadata: Metadata) {
			let newNFT <- create NFT(metadata: metadata)
            let id = newNFT.id
			//recipient.deposit(token: <-newNFT)  // deposit it in the recipient's account using their reference
            DAAM.collection.deposit(token: <- newNFT)
            emit MintedNFT(id: id)
		}
    }
/************************************************************************/
    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // DAAM Functions
	init() {
        // init Paths
        self.collectionPublicPath  = /public/DAAMCollection
        self.collectionStoragePath = /storage/DAAMCollection
        self.adminPublicPath       = /public/DAAMAdmin
        self.adminPrivatePath      = /private/DAAMAdmin
        self.adminStoragePath      = /storage/DAAMAdmin
        self.artistPrivatePath     = /private/DAAMArtist
        self.artistStoragePath     = /storage/DAAMArtist

        //Custom variables should be contract arguments
        
        self.adminPending = 0x01cf0e2f2f715450

        self.artist = {}
        self.totalSupply = 0                    // Initialize the total supply of NFTs
        self.collectionCounterID = 0            // Incremental Serial Number for the Collections   
        self.collection <- create Collection()  // Create a Collection resource and save it to storage
        //self.account.save(<-collection, to: self.collectionStoragePath)

        // create a public capability for the collection
        //self.account.link<&{NonFungibleToken.CollectionPublic}>(self.collectionPublicPath, target: self.collectionStoragePath)

        // Create a Minter resource and save it to storage
        let admin <- create Admin()
        self.account.save(<-admin, to: self.adminStoragePath)
        self.account.link<&Admin{InvitedAdmin, InvitedArtist}>(self.adminPublicPath, target: self.adminStoragePath)

        emit ContractInitialized()
	}
}

