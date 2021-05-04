// This is an example implementation of a Flow Non-Fungible Token
// It is not part of the official standard but it assumed to be
// very similar to how many NFTs would implement the core functionality.

import NonFungibleToken from 0xf8d6e0586b0a20c7
import Profile from 0xf8d6e0586b0a20c7

pub contract DAAM: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub let collectionPublicPath : PublicPath
    pub let collectionStoragePath: StoragePath
    //pub let minterPublicPath : PublicPath
    pub let minterStoragePath: StoragePath

    access(contract) var artist: [Address]
    
    pub var collectionCounterID: UInt64
    pub var collection: @Collection

    // Metadata for NFT,metadata initialization
    pub struct Metadata {
        pub let title: String              // Title
        pub let format: String             // File format
        pub let file: String               // File           
        pub let creator: Address   // TODO FIX Artist        
        pub let about: String                // About NFT, Blurb or website
        pub let isPhysical: String             // Does this have a physical counter-part
        pub let series: String      // If, Part of which series  TODO FIX UPGRADE to NFT
        pub let agency: String               // Sold from which Gallery or Online // UPGRADE to NFT
        pub let thumbnail_format: String     // Thumbnail format
        pub let thumbnail: String            // Thumbnail             

        init(title:String, format:String, file: String, creator:Address, about:String, physical:String,
            series:String, agency:String, thumbnail_format:String, thumbnail:String) {
            self.title = title
            self.format = format
            self.file = file            
            self.creator = creator            
            self.about = about
            self.isPhysical = physical
            self.series = series
            self.agency = agency
            self.thumbnail_format = thumbnail_format
            self.thumbnail = thumbnail            
        }// Metadata init
    }// Metadata

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub var metadata: Metadata

        init(metadata: Metadata) {
            DAAM.totalSupply = DAAM.totalSupply + 1 as UInt64
            self.id = DAAM.totalSupply
            self.metadata = metadata
        }
    }

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

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub resource Admin {
        //pub fun createAdmin()
    }

    // Resource that an admin or something similar would own to be able to mint new NFTs
	pub resource NFTMinter {
		// mintNFT mints a new NFT with a new ID and deposit it in the recipients collection using their collection reference
		pub fun mintNFT(metadata: Metadata) {
			var newNFT <- create NFT(metadata: metadata)			
			//recipient.deposit(token: <-newNFT)  // deposit it in the recipient's account using their reference
            DAAM.collection.deposit(token: <- newNFT)
		}
	}

    pub fun addArtist(_ artist: Address) {  // Admin add a new artist
            pre {
                !DAAM.artist.contains(artist) : "They're already a D.A.A.M Artist!!!"
                Profile.check(artist)               : "You can't add an artist with a Profile!"
            }            
            DAAM.artist.append(artist)
    }

	init() {
        // init Paths
        self.collectionPublicPath  = /public/DAAMCollection
        self.collectionStoragePath = /storage/DAAMCollection
        //self.minterPublicPath  = /public/DAAMMinter
        self.minterStoragePath = /storage/DAAMMinter

        self.artist = []
        self.totalSupply = 0                    // Initialize the total supply of NFTs
        self.collectionCounterID = 0            // Incremental Serial Number for the Collections   
        self.collection <- create Collection()  // Create a Collection resource and save it to storage
        //self.account.save(<-collection, to: self.collectionStoragePath)

        // create a public capability for the collection
        //self.account.link<&{NonFungibleToken.CollectionPublic}>(self.collectionPublicPath, target: self.collectionStoragePath)

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.minterStoragePath)

        emit ContractInitialized()
	}
}

