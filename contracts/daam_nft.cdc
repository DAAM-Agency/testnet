// marketPalace.cdc

import NonFungibleToken from 0x120e725050340cab
import FungibleToken    from 0xee82856bf20e2aa6
import Profile          from 0x192440c99cb17282
import DAAMCopyright    from 0xe03daebed8ca0615
/************************************************************************/
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
    access(contract) var artist: {Address: Bool}
    access(contract) var adminPending : Address?
    
    access(contract) var collectionCounterID: UInt64
    access(contract) var collection: @{Address: Collection}

    //access(contract) var DAAMPublicCollection: @SalePublic
/************************************************************************/
    pub struct Metadata {  // Metadata for NFT,metadata initialization
        pub let creator   : Address   // Artist
        pub let data      : String    // JSON see metadata.json
        pub let thumbnail : String    // JSON see metadata.json
        pub let file      : String    // JSON see metadata.json
             

        init(creator: Address, metadata: String, thumbnail: String, file: String)
        {
            self.creator = creator
            self.data = metadata
            self.thumbnail = thumbnail
            self.file = file            
        }// Metadata init
    }// Metadata
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT {
        pub let id       : UInt64
        pub let metadata : Metadata
        access(self) var copyright: Capability<&DAAMCopyright>
        //pub var series  : [UInt64]?  // TokenIDs of series

        init(metadata: Metadata) {
            self.metadata = metadata
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply
            let daamCopyright = getAccount(0xe03daebed8ca0615)
            self.copyright = daamCopyright.getCapability<&DAAMCopyright>(/public/Unverifed)
            DAAMCopyright.copyrightInformation[self.id] = DAAMCopyright.CopyrightStatus.UNVERIFIED
            //self.series = []
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
            self.id = DAAM.collectionCounterID
            DAAM.collectionCounterID = DAAM.collectionCounterID + 1 as UInt64
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
                DAAM.artist[artist] == nil : "They're already a DAAM Artist!!!"
                Profile.check(artist)      : "You can't be a DAAM Artist without a Profile! Go make one Fool!!"
            }
        }

        pub fun setCopyrightInformation(tokenID: UInt64, copyright: DAAMCopyright.CopyrightStatus) {
            pre {
                DAAMCopyright.copyrightInformation[tokenID] != nil : "Invalid NFT ID"
            }
        }
    }
/************************************************************************/
    pub resource interface InvitedAdmin {
        pub fun answerAdminInvite(_ newAdmin: Address,_ submit: Bool): @Admin{Founder} {
            pre {
                DAAM.adminPending == newAdmin : "You got no DAAM Admin invite!!!. Get outta here!!"
                Profile.check(newAdmin)       : "You can't be a DAAM Admin without a Profile first! Go make one Fool!!"
                submit == true                : "Well, ... fuck you too!!!"
            }      
        }        
    }
/************************************************************************/
    pub resource interface InvitedArtist {
        pub fun answerArtistInvite(artist: Address, answer: Bool): @Artist {
            pre {
                DAAM.artist[artist] != nil : "You got no DAAM Artist invite!!!. Get outta here!!"
                Profile.check(artist)      : "You can't be a DAAM Artist without a Profile first! Go make one Fool!!"
                answer == true             : "OK ?!? Then why the fuck did you even bother ?!?"
            }
        }
    }
/************************************************************************/
	pub resource Admin: Founder, InvitedAdmin, InvitedArtist
    {
        pub fun inviteAdmin(newAdmin: Address) {
            emit AdminInvited(admin: newAdmin)
            log("Sent Admin Invation: ".concat(newAdmin.toString()) )
            DAAM.adminPending = newAdmin
            // TODO Add time limit
        }

        pub fun inviteArtist(_ artist: Address) {  // Admin add a new artist
            emit ArtistInvited(artist: artist)
            log("Sent Artist Invation: ".concat(artist.toString()) )
            DAAM.artist[artist] = false
            // TODO Add time limit
        }

        pub fun answerAdminInvite(_ newAdmin: Address,_ submit: Bool): @Admin{Founder} {
            pre {
                DAAM.adminPending == newAdmin : "You got no DAAM Admin invite!!!. Get outta here!!"
                Profile.check(newAdmin)       : "You can't be a DAAM Admin without a Profile first! Go make one Fool!!"
                submit == true                : "Well, ... fuck you too!!!"
            }
            DAAM.adminPending = nil
            emit NewAdmin(admin: newAdmin)
            log("Admin: ".concat(newAdmin.toString()).concat(" added to DAAM") )
            return <- create Admin()         
        }
        // TODO add interface restriction to collection
        pub fun answerArtistInvite(artist: Address, answer: Bool): @Artist {
            pre {
                DAAM.artist[artist] != nil : "You got no DAAM Artist invite!!!. Get outta here!!"
                Profile.check(artist)      : "You can't be a DAAM Artist without a Profile first! Go make one Fool!!"
                answer == true             : "OK ?!? Then why the fuck did you even bother ?!?"
            }
            DAAM.artist[artist] = true
            DAAM.collection[artist] <-! create Collection()
            emit NewArtist(artist: artist)
            log("Artist: ".concat(artist.toString()).concat(" added to DAAM") )
            return <- create Artist()
        }

        pub fun setCopyrightInformation(tokenID: UInt64, copyright: DAAMCopyright.CopyrightStatus) {            
            DAAMCopyright.copyrightInformation[tokenID] = copyright
            emit SetCopyright(tokenID: tokenID)
            log("NFT: ".concat(" Copyright Updated") )
        }

        //pub fun removeArtist()
        //pub fun freezeArtist()

        // TODO self destruct Remove Admin is missing
        // pub fun removeAdmin() {}
	}
/************************************************************************/
    pub resource Artist {
        // mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: Metadata) {
		//pub fun mintNFT(recipient: Address, metadata: Metadata) {
			let newNFT <-! create NFT(metadata: metadata)
            let id = newNFT.id
			recipient.deposit(token: <-newNFT)  // deposit it in the recipient's account using their reference

            //var collection = &DAAM.collection[recipient] as &{NonFungibleToken.CollectionPublic}
            //collection.deposit(token: <- newNFT)
            emit MintedNFT(id: id)
            log("Minited NFT: ".concat(id.toString()))
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
        //self.DAAMPublicCollection <- create SalePublic()

        self.artist = {}
        self.totalSupply = 0                    // Initialize the total supply of NFTs
        self.collectionCounterID = 0            // Incremental Serial Number for the Collections   
        self.collection <- {}
        
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

