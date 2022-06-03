// daam_nft.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken    from 0x9a0766d93b6608b7 
import MetadataViews    from 0x1784abd15a9f29a8
import Profile          from 0xba1132bc08f82fe2
import Categories       from 0xa4ad5ea5c0bd2fba

/************************************************************************/
pub contract DAAM_V11: NonFungibleToken {
    // Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?) // Collection Wallet, used to withdraw NFT
    pub event Deposit(id: UInt64, to: Address?)  // Collection Wallet, used to deposit NFT
    // Events
    pub event NewAdmin(admin  : Address)         // A new Admin has been added. Accepted Invite
    pub event NewAgent(agent  : Address)         // A new Agent has been added. Accepted Invite
    pub event NewMinter(minter: Address)         // A new Minter has been added. Accepted Invite
    pub event NewCreator(creator: Address)       // A new Creator has been added. Accepted Invite
    pub event AdminInvited(admin  : Address)     // Admin has been invited
    pub event AgentInvited(agent  : Address)     // Agent has been invited
    pub event CreatorInvited(creator: Address)   // Creator has been invited
    pub event MinterSetup(minter: Address)       // Minter has been invited
    pub event AddMetadata(creator: Address, mid: UInt64) // Metadata Added
    pub event MintedNFT(creator: Address, id: UInt64)              // Minted NFT
    pub event ChangedCopyright(metadataID: UInt64) // Copyright has been changed to a MID 
    pub event ChangeAgentStatus(agent: Address, status: Bool)     // Agent Status has been changed by Admin
    pub event ChangeCreatorStatus(creator: Address, status: Bool) // Creator Status has been changed by Admin/Agemnt
    pub event ChangeMinterStatus(minter: Address, status: Bool)    // Minter Status has been changed by Admin
    pub event AdminRemoved(admin: Address)       // Admin has been removed
    pub event AgentRemoved(agent: Address)       // Agent has been removed by Admin
    pub event CreatorRemoved(creator: Address)   // Creator has been removed by Admin
    pub event MinterRemoved(minter: Address)     // Minter has been removed by Admin
    pub event RequestAccepted(mid: UInt64)       // Royalty rate has been accepted 
    pub event RemovedMetadata(mid: UInt64)       // Metadata has been removed by Creator
    pub event RemovedAdminInvite(admin : Address)               // Admin invitation has been rescinded
    // Paths
    pub let collectionPublicPath  : PublicPath   // Public path to Collection
    pub let collectionStoragePath : StoragePath  // Storage path to Collection
    pub let metadataPublicPath    : PublicPath   // Public path that to Metadata Generator: Requires Admin/Agent  or Creator Key
    pub let metadataStoragePath   : StoragePath  // Storage path to Metadata Generator
    pub let adminPrivatePath      : PrivatePath  // Private path to Admin 
    pub let adminStoragePath      : StoragePath  // Storage path to Admin 
    pub let minterPrivatePath     : PrivatePath  // Private path to Minter
    pub let minterStoragePath     : StoragePath  // Storage path to Minter
    pub let creatorPrivatePath    : PrivatePath  // Private path to Creator
    pub let creatorStoragePath    : StoragePath  // Storage path to Creator
    pub let requestPrivatePath    : PrivatePath  // Private path to Request
    pub let requestStoragePath    : StoragePath  // Storage path to Request
    // Variables
    pub var totalSupply : UInt64 // the total supply of NFTs, also used as counter for token ID
    access(contract) var remove  : {Address: Address} // Requires 2 Admins to remove an Admin, the Admins are stored here. {Voter : To Remove}
    access(contract) var admins  : {Address: Bool}    // {Admin Address : status}  Admin address are stored here
    access(contract) var agents  : {Address: Bool}    // {Agents Address : status} Agents address are stored here // preparation for V2
    access(contract) var minters : {Address: Bool}    // {Minters Address : status} Minter address are stored here // preparation for V2
    access(contract) var creators: {Address: CreatorInfo}    // {Creator Address : status} Creator address are stored here
    access(contract) var metadata: {UInt64 : Bool}    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var metadataCap: {Address : Capability<&MetadataGenerator{MetadataGeneratorPublic}> }    // {MID : Approved by Admin } Metadata ID status is stored here
    access(contract) var request : @{UInt64: Request} // {MID : @Request } Request are stored here by MID
    access(contract) var copyright: {UInt64: CopyrightStatus} // {NFT.id : CopyrightStatus} Get Copyright Status by Token ID
    // Variables 
    access(contract) var metadataCounterID : UInt64   // The Metadta ID counter for MetadataID.
    access(contract) var newNFTs: [UInt64]    // A list of newly minted NFTs. 'New' is defined as 'never sold'. Age is Not a consideration.
    pub let agency : MetadataViews.Royalties  // DAAM_V11 Ageny Address
/***********************************************************************/
// Copyright enumeration status // Worst(0) to best(4) as UInt8
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD      // 0 as UInt8
            pub case CLAIM      // 1 as UInt8
            pub case UNVERIFIED // 2 as UInt8
            pub case VERIFIED   // 3 as UInt8
}
/***********************************************************************/
pub struct CreatorInfo {
    pub let creator: {Address: MetadataViews.Royalty}
    pub(set) var status: Bool?
    pub(set) var agent: {Address: MetadataViews.Royalty} // Agent & Percentage

    init(creator: {Address: MetadataViews.Royalty}, agent: {Address: MetadataViews.Royalty}?, status: Bool)
    {
        self.creator = creator // element 0 is reserved for Creator
        self.status = status
        self.agent = (agent!=nil) ? agent! : {}
    }
}
/***********************************************************************/
// Used to make requests for royalty. A resource for Neogoation of royalities.
// When both parties agree on 'royalty' the Request is considered valid aka isValid() = true and
// Request manage the royalty rate
// Accept Default are auto agreements
pub resource Request {
    access(contract) let mid       : UInt64                  // Metadata ID number is stored
    access(contract) var royalty   : MetadataViews.Royalties? // current royalty neogoation.
    access(contract) var agreement : [Bool; 2]               // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(mid: UInt64) {
        self.mid = mid          // Get Metadata ID
        DAAM_V11.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
        self.royalty = nil               // royalty is initialized
        self.agreement = [false, false]  // [Agency/Admin, Creator] are both set to disagree by default
    }

    pub fun getMID(): UInt64 { return self.mid }  // return Metadata ID
    
    // Neogatator Removed, Re-Add Here, if re-implimented.

    // Accept Default royalty. Skip Neogations.
    access(contract) fun acceptDefault(royalty: MetadataViews.Royalties ) {
        self.royalty = royalty        // get royalty
        self.agreement = [true, true] // set agreement status to Both parties Agreed
    }

    // If both parties agree (Creator & Admin) return true
    pub fun isValid(): Bool { return self.agreement[0]==true && self.agreement[1]==true }
}    
/***********************************************************************/
// Used to create Request Resources. Metadata ID is passed into Request.
// Request handle Royalities, and Negoatons.
pub resource RequestGenerator {
    priv let grantee: Address

    init(_ grantee: Address) { self.grantee = grantee }

    // Accept the default Request. No Neogoation is required.
    // Percentages are between 10% - 30%
    pub fun acceptDefault(mid: UInt64, metadataGen: &MetadataGenerator{MetadataGeneratorPublic}, percentage: UFix64) {
        pre {
            self.grantee == self.owner!.address     : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
            metadataGen.getMIDs().contains(mid)     : "MID: ".concat(mid.toString()).concat(" is Incorrect")
            DAAM_V11.creators.containsKey(self.grantee) : "Account: ".concat(self.grantee.toString()).concat("You are not a Creator")
            DAAM_V11.isCreator(self.grantee) == true    : "Account: ".concat(self.grantee.toString()).concat("Your Creator account is Frozen.")
            percentage >= 0.1 && percentage <= 0.3  : "Percentage must be inbetween 10% to 30%."
        }
        // Getting Agency royalties
        //let agency   = DAAM_V11.agency.getRoyalties()
        let creators = metadataGen.viewMetadata(mid: mid)!.creatorInfo.creator // creatorInfo.creators[0]
        let fee = 0.025
        let creatorCut = percentage / (1.0 + fee)// Add Creator percentage
        //let agencyCut  = percentage - creatorCut // Add Agency percentage, Agency takes 10% of Creator
        var royalty_list: [MetadataViews.Royalty] = []

        /*for founder in agency {
            royalty_list.append(
                MetadataViews.Royalty(
                    recepient: founder.receiver,
                    cut: agencyCut * founder.cut,
                    description: "Agency")
            ) // end append   
        }*/

        for creator in creators.keys {
            royalty_list.append(
                MetadataViews.Royalty(
                    recepient: getAccount(creator).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver),//creator!.receiver,
                    cut: creatorCut * creators[creator]!.cut,
                    description: "Creator")
            ) // end append   
        }        

        let request <-! create Request(mid: mid) // get request
        let royalties = MetadataViews.Royalties(royalty_list)
        request.acceptDefault(royalty: royalties)  // append royalty rate

        let old <- DAAM_V11.request.insert(key: mid, <-request) // advice DAAM_V11 of request
        destroy old // destroy place holder
        
        log("Request Accepted, MID: ".concat(mid.toString()) )
        emit RequestAccepted(mid: mid)
    }
}
/************************************************************************/
    pub struct MetadataHolder {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let mid         : UInt64
        pub let creatorInfo : CreatorInfo  // Creator of NFT
        pub let edition     : MetadataViews.Edition   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let category    : [Categories.Category]
        pub let inCollection    : [UInt64]?
        pub let description : String   // JSON see metadata.json all data ABOUT the NFT is stored here
        pub let thumbnail   : {String : {MetadataViews.File}}   // JSON see metadata.json all thumbnails are stored here
        
        init(creators: CreatorInfo, mid: UInt64, edition: MetadataViews.Edition, categories: [Categories.Category], inCollection: [UInt64]?,
            description: String, thumbnail: {String : {MetadataViews.File}})
        {
            self.mid         = mid
            self.creatorInfo = creators     // creator of NFT
            self.edition     = edition      // total prints
            self.category    = categories
            self.inCollection    = inCollection     // total prints
            self.description = description  // data,about,misc page
            self.thumbnail   = thumbnail    // thumbnail are stored here
        }
    }
/************************************************************************/
    pub resource Metadata {  // Metadata struct for NFT, will be transfered to the NFT.
        pub let mid         : UInt64   // Metadata ID number
        pub let creatorInfo : CreatorInfo  // Creator of NFT
        pub let edition     : MetadataViews.Edition   // series total, number of prints. 0 = Unlimited [counter, total]
        pub let category    : [Categories.Category]
        pub var inCollection    : [UInt64]?
        pub let description : String   // JSON see metadata.json all data ABOUT the NFT is stored here
        pub let thumbnail   : {String : {MetadataViews.File}}   // JSON see metadata.json all thumbnails are stored here
        pub let file        : {String : MetadataViews.Media}   // JSON see metadata.json all NFT file formats are stored here

        init(creators: CreatorInfo?, name: String?, max: UInt64?, categories: [Categories.Category]?, inCollection: [UInt64]?, description: String?,
            thumbnail: {String:{MetadataViews.File}}?, file: {String:MetadataViews.Media}?, metadata: &Metadata?)
        {            
            pre {
                max != 0 : "Max has an incorrect value of 0."
                // Increment Metadata Counter; Make sure Arguments are blank except for Metadata; This also excludes all non consts
                (creators==nil && name==nil && categories==nil && description==nil && thumbnail==nil && file==nil &&
                metadata != nil)
                || // or
                // New Metadata (edition.number = 1) Make sure Arguments are full except for Metadata; This also excludes all non consts
                (creators!=nil && name!=nil && categories!=nil && description!=nil && thumbnail!=nil && file!=nil && metadata == nil)
            }

            if metadata == nil {
                DAAM_V11.metadataCounterID = DAAM_V11.metadataCounterID + 1
                self.mid         = DAAM_V11.metadataCounterID // init MID with counter
                self.creatorInfo = creators!               // creator of NFT
                self.edition     = MetadataViews.Edition(name: name, number: 1, max: max) // total prints
                self.category    = categories!            // categories 
                self.description = description!           // data,about,misc page
                self.thumbnail   = thumbnail!             // thumbnail are stored here
                self.file        = file!                  // NFT data is stored hereere
                // is not Constant or Optional
                self.inCollection = inCollection 
            } else {                
                self.mid         = metadata!.mid         // init MID with counter
                self.creatorInfo = metadata!.creatorInfo // creator of NFT
                self.edition     = MetadataViews.Edition(name: metadata!.edition.name, number: metadata!.edition.number+1, max: metadata!.edition.max) // Total prints
                self.category    = metadata!.category    // categories 
                self.description = metadata!.description // data,about,misc page
                self.thumbnail   = metadata!.thumbnail   // thumbnail are stored here
                self.file        = metadata!.file
                self.inCollection = metadata!.inCollection
                // Error checking; Re-prints do not excede series limit or is Unlimited prints
                if(metadata!.edition.max != nil) { assert(metadata!.edition.number <= metadata!.edition.max!, message: "Metadata prints are finished.") }
            }
        }

        pub fun getHolder(): MetadataHolder {
            return MetadataHolder(creators: self.creatorInfo, mid: self.mid, edition: self.edition, categories: self.category,
                inCollection: self.inCollection, description: self.description, thumbnail: self.thumbnail )
        }
        
        // MetadataViews
        pub fun getDisplay(): MetadataViews.Display {
            let display = MetadataViews.Display(name: self.edition.name!, description: self.description, thumbnail: self.thumbnail[self.thumbnail.keys[0]]!)
            return display
        }

        //pub fun getViews(): [Type] {}
        //pub fun resolveView(_ view: Type): AnyStruct?
    }
/************************************************************************/
pub struct OnChain: MetadataViews.File {
    priv let data: String
    init(file: String) { self.data = file }
    pub fun uri(): String {return self.data }
}
/************************************************************************/
pub resource interface MetadataGeneratorMint {
    // Used to generate a Metadata either new or one with an incremented counter
    // Requires a Minters Key to generate MinterAccess
    pub fun generateMetadata(minter: @MinterAccess, mid: UInt64) : @Metadata
}
/************************************************************************/
pub resource interface MetadataGeneratorPublic {
    pub fun getMIDs(): [UInt64]
    pub fun viewMetadata(mid: UInt64): MetadataHolder?
    pub fun viewMetadatas(): [MetadataHolder]
    pub fun viewDisplay(mid: UInt64): MetadataViews.Display?
    pub fun viewDisplays(): [MetadataViews.Display]
}
/************************************************************************/
// Verifies each Metadata gets a Metadata ID, and stores the Creators' Metadatas'.
pub resource MetadataGenerator: MetadataGeneratorPublic, MetadataGeneratorMint {
        // Variables
        priv var metadata : @{UInt64 : Metadata} // {MID : Metadata Resource}
        priv let grantee: Address

        init(_ grantee: Address) {
            self.metadata <- {}  // Init Metadata
            self.grantee = grantee
            DAAM_V11.metadataCap.insert(key: self.grantee, getAccount(self.grantee).getCapability<&MetadataGenerator{MetadataGeneratorPublic}>(DAAM_V11.metadataPublicPath))
        }


        // addMetadata: Used to add a new Metadata. This sets up the Metadata to be approved by the Admin. Returns the new mid.
        pub fun addMetadata(name: String, max: UInt64?, categories: [Categories.Category], inCollection: [UInt64]?, description: String,
            thumbnail: {String:{MetadataViews.File}}, file: {String:MetadataViews.Media} ): UInt64
        {
            pre{
                self.grantee == self.owner!.address     : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                DAAM_V11.creators.containsKey(self.grantee) : "Account: ".concat(self.grantee.toString()).concat("You are not a Creator")
                DAAM_V11.isCreator(self.grantee) == true    : "Account: ".concat(self.grantee.toString()).concat("Your Creator account is Frozen.")
            }

            let metadata <- create Metadata(creators: DAAM_V11.creators[self.grantee], name: name, max: max, categories: categories, inCollection: inCollection,
                description: description, thumbnail: thumbnail, file: file, metadata: nil) // Create Metadata
            let mid = metadata.mid
            let old <- self.metadata[mid] <- metadata // Save Metadata
            destroy old

            DAAM_V11.metadata.insert(key: mid, false)   // a metadata ID for Admin approval, currently unapproved (false)
            DAAM_V11.copyright.insert(key: mid, CopyrightStatus.UNVERIFIED) // default copyright setting

            DAAM_V11.metadata[mid] = true // TODO REMOVE AUTO-APPROVE AFTER DEVELOPMENT

            log("Metadata Generatated ID: ".concat(mid.toString()) )
            emit AddMetadata(creator: self.grantee, mid: mid)
            return mid
        }

        // RemoveMetadata uses clearMetadata to delete the Metadata.
        // But when deleting a submission the request must also be deleted.
        pub fun removeMetadata(mid: UInt64) {
            pre {
                self.grantee == self.owner!.address     : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                DAAM_V11.creators.containsKey(self.grantee) : "Account: ".concat(self.grantee.toString()).concat("You are not a Creator")
                DAAM_V11.isCreator(self.grantee) == true    : "Account: ".concat(self.grantee.toString()).concat("Your Creator account is Frozen.")
                self.metadata[mid] != nil               : "MetadataID: ".concat(mid.toString()).concat(" does not exist.")
            }
            let old_meta <- self.clearMetadata(mid: mid)  // Delete Metadata
            destroy old_meta

            let old_request <- DAAM_V11.request.remove(key: mid)  // Get Request
            destroy old_request // Delete Request
        }

        // Used to remove Metadata from the Creators metadata dictionary list.
        priv fun clearMetadata(mid: UInt64): @Metadata {            
            DAAM_V11.metadata.remove(key: mid) // Metadata removed from DAAM_V11. Logging no longer neccessary
            DAAM_V11.copyright.remove(key:mid) // remove metadata copyright            
            
            log("Destroyed Metadata")
            emit RemovedMetadata(mid: mid)

            return <- self.metadata.remove(key: mid)! // Metadata removed. Metadata Template has reached its max count (edition)
        }
        // Remove Metadata as Resource. Metadata + Request = NFT.
        // The Metadata will be destroyed along with a matching Request (same MID) in order to create the NFT
        pub fun generateMetadata(minter: @MinterAccess, mid: UInt64) : @Metadata {
            pre {
                self.grantee == self.owner!.address     : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                minter.validate()                       : "Account: ".concat(self.owner!.address.toString()).concat("Minter Access Denied")
                DAAM_V11.creators.containsKey(self.grantee) : "Account: ".concat(self.grantee.toString()).concat("You are not a Creator")
                DAAM_V11.isCreator(self.grantee) == true    : "Account: ".concat(self.grantee.toString()).concat("Your Creator account is Frozen.")
                
                self.metadata[mid] != nil : "MetadataID: ".concat(mid.toString()).concat(" does not exist.")
                DAAM_V11.metadata[mid] != nil : "MetadataID: ".concat(mid.toString()).concat(" This already has been published.")
                DAAM_V11.metadata[mid]!       : "MetadataID: ".concat(mid.toString()).concat(" Submission has been Disapproved.")
            }
            destroy minter

            // Create Metadata with incremented counter/print
            let mRef = &self.metadata[mid] as &Metadata?

            // Verify Metadata Counter (print) is not last, if so delete Metadata
            if mRef!.edition.max != nil {
                if mRef!.edition.number < mRef!.edition.max! {            
                    let new_metadata <- create Metadata(creators:nil, name:nil, max:nil, categories:nil, inCollection:nil,
                        description:nil, thumbnail:nil, file:nil, metadata: mRef)
                    let orig_metadata <- self.metadata[mid] <- new_metadata // Update to new incremented (counter) Metadata
                    return <- orig_metadata! // Return current Metadata
                }
                panic("Metadata Prints Finished.")
            } // if not last, print
            let orig_metadata <- self.clearMetadata(mid: mid) // Remove metadata template
            return <- orig_metadata! // Return current Metadata  
        }

        pub fun getMIDs(): [UInt64] { // Return specific MIDs of Creator
            return self.metadata.keys
        }

        pub fun viewMetadata(mid: UInt64): MetadataHolder? {
            pre { self.metadata[mid] != nil : "MetadataID: ".concat(mid.toString()).concat(" is not a valid Entry.") }
            let mRef = &self.metadata[mid] as &Metadata?
            let data: MetadataHolder? = mRef!.getHolder() // as MetadataHolder// as &Metadata
            return data
        }

        pub fun viewMetadatas(): [MetadataHolder] {
            var list: [MetadataHolder] = []
            for m in self.metadata.keys {
                let mRef = &self.metadata[m] as &Metadata?
                list.append(mRef!.getHolder() )
            } 
            return list
        }

        pub fun viewDisplay(mid: UInt64): MetadataViews.Display? {
            pre { self.metadata[mid] != nil : "MetadataID: ".concat(mid.toString()).concat(" is not a valid Entry.") }
            let mRef = &self.metadata[mid] as &Metadata?
            return mRef!.getDisplay()
        }

        pub fun viewDisplays(): [MetadataViews.Display] {
            var list: [MetadataViews.Display] = []
            for m in self.metadata.keys {
                let mRef = &self.metadata[m] as &Metadata?
                list.append(mRef!.getDisplay() )
            } 
            return list
        }

        destroy() { destroy self.metadata } 
}
/************************************************************************/
    pub resource interface INFT {
        pub let mid      : UInt64                   // Metadata ID, A unique serialized number
        pub let metadata : MetadataHolder           // Metadata of NFT
        pub let royalty  : MetadataViews.Royalties // All royalities percentages
    }
/************************************************************************/
    pub resource NFT: NonFungibleToken.INFT, INFT {
        pub let id       : UInt64   // Token ID, A unique serialized number
        pub let mid      : UInt64   // Metadata ID, A unique serialized number
        pub let metadata : MetadataHolder          // Metadata of NFT
        pub let royalty  : MetadataViews.Royalties // Where all royalities are stored {Address : percentage} Note: 1.0 = 100%

        init(metadata: @Metadata, request: &Request?) {
            pre { metadata.mid == request!.mid : "Metadata and Request have different MIDs. They are not meant for each other."}
            
            DAAM_V11.totalSupply = DAAM_V11.totalSupply + 1 // Increment total supply
            self.id          = DAAM_V11.totalSupply     // Set Token ID with total supply
            self.mid         = metadata.mid         // Set Metadata ID
            self.royalty     = request!.royalty!     // Save Request which are the royalities.  
            self.metadata    = metadata.getHolder() // Save Metadata from Metadata Holder
            destroy metadata                        // Destroy no loner needed container Metadata Holder
        }

        pub fun getCopyright(): CopyrightStatus { // Get current NFT Copyright status
            return DAAM_V11.copyright[self.id]! // return copyright status
        }
    }
/************************************************************************/
// Wallet Public standards. For Public access only
pub resource interface CollectionPublic {
    pub fun borrowDAAM_V11(id: UInt64): &DAAM_V11.NFT? // Get NFT as DAAM_V11.NFT
    pub fun getPersonalCollection(): {String: PersonalCollection}
}
/************************************************************************/
pub struct PersonalCollection {
    pub var id: [UInt64]
    pub var personalCollections: [String]

    init(id: UInt64) {
        post { self.id.length == 1 }
        self.id = [id]
        self.personalCollections = []
    }

    pub fun appendID(_ id: UInt64) { self.id.append(id) }
    pub fun removeID(at: UInt64) { self.id.remove(at: at) }

    pub fun appendCollection(_ collection: String) { self.personalCollections.append(collection) }
    pub fun removeCollection(at: UInt64) { self.personalCollections.remove(at: at) }
}
// Standand Flow Collection Wallet
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens. NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs   : @{UInt64: NonFungibleToken.NFT}  // Store NFTs via Token ID
        pub var collections : {String: PersonalCollection}
        
        // {name : MetadataViews.NFTCollectionData } // TODO
                        
        init() {
            self.ownedNFTs <- {} // List of owned NFTs
            self.collections = {}
        }

        // adds to a personal collection, has no actual bearing on nfts. The same NFTs can be added to multiple personal collections
        pub fun addToPersonalCollection(collectionName: String, tokenID: UInt64) {
            pre { self.ownedNFTs.containsKey(tokenID) : "Can not add an NFT you do not have into a Personal Collection." } 
                if self.collections.containsKey(collectionName) {
                    if !self.collections[collectionName]!.id.contains(tokenID) { self.collections[collectionName]!.appendID(tokenID) }
                } else {
                    self.collections.insert(key:collectionName, PersonalCollection(id: tokenID))
                }
        }

        // remvoves NFT from ALL person collection when name is nill, otherwise the specific Personal Collection.
        pub fun removeFromPersonalCollection(collectionName: String?, tokenID: UInt64) {
            pre { self.ownedNFTs.containsKey(tokenID) : "Can not remove an NFT you do not have from any Personal Collection." }
            assert(collectionName == nil || self.collections.containsKey(collectionName!), message: "This Personal Collection does not exist.")

            var counter: UInt64 = 0
            if collectionName == nil {
                for key in self.collections.keys {
                    if !self.collections[key]!.id.contains(tokenID) { continue }
                    self.collections[key]!.removeID(at: counter)
                    counter = counter + 1
                }
            }else {
                for key in self.collections[collectionName!]!.id { 
                    if key != tokenID { continue }
                    self.collections[collectionName!]!.removeID(at: counter)
                    counter = counter + 1
                }

            }
        } 

        // Add a Personal Collection to a Personal Collection
        pub fun addPersonalCollection(addCollection: String, collectionName: String) {
            pre {
                self.collections.containsKey(addCollection)       : "Personal Collection: ".concat(addCollection).concat(" does not exist.")
                self.collections.containsKey(collectionName) : "Personal Collection: ".concat(collectionName).concat(" does not exist.")
                !self.collections[addCollection]!.personalCollections.contains(collectionName) : "Already added."
            }
            self.collections[addCollection]!.appendCollection(collectionName)
        }

        pub fun removePersonalCollection(remove: String, collectionName: String?) {
            assert(collectionName == nil || self.collections.containsKey(collectionName!), message: "This Personal Collection does not exist.")
            var counter: UInt64 = 0 
            if collectionName == nil {
                for key in self.collections.keys {
                    if !self.collections[key]!.personalCollections.contains(remove) { continue }
                    self.collections[key]!.removeCollection(at: counter) 
                    counter = counter + 1
                }
            }else {
                for key in self.collections[collectionName!]!.personalCollections {
                    if key != remove { continue }
                    self.collections[collectionName!]!.removeCollection(at: counter)
                    counter = counter + 1
                }
            }
        }

        pub fun getPersonalCollection(): {String: PersonalCollection} { return self.collections }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            self.removeFromPersonalCollection(collectionName: nil, tokenID: withdrawID)
            let token <- self.ownedNFTs.remove(key: withdrawID)! as! @DAAM_V11.NFT // Get NFT
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @DAAM_V11.NFT // Get NFT as DAAM_V11.GFT
            let id = token.id        // Save Token ID
            let name = token.metadata.edition.name!
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token   // Store NFT
            self.addToPersonalCollection(collectionName: name, tokenID: id)
            emit Deposit(id: id, to: self.owner?.address) 
            destroy oldToken                              // destroy place holder
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] { return self.ownedNFTs.keys }        

        // borrowNFT gets a reference to an NonFungibleToken.NFT in the collection.
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT { return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)! }

        // borrowDAAM_V11 gets a reference to an DAAM_V11.NFT in the album.
        pub fun borrowDAAM_V11(id: UInt64): &DAAM_V11.NFT {
            pre { self.ownedNFTs[id] != nil : "Your Collection is empty." }
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT? // Get reference to NFT
            return ref as! &DAAM_V11.NFT                                    // return NFT Reference
        }

        destroy() { destroy self.ownedNFTs } // Destructor
    }
/************************************************************************/
// Agent interface. List of all powers belonging to the Agent
    pub resource interface Agent 
    {
        pub var status: Bool // the current status of the Admin

        pub fun inviteCreator(_ creator: Address)                   // Admin invites a new creator       
        pub fun changeCreatorStatus(creator: Address, status: Bool) // Admin or Agent change Creator status        
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) // Admin or Agenct can change MID copyright status
        pub fun changeMetadataStatus(mid: UInt64, status: Bool)     // Admin or Agent can change Metadata Status
        pub fun removeCreator(creator: Address)                     // Admin or Agent can remove CAmiRajpal@hotmail.cometadata Status
        pub fun newRequestGenerator(): @RequestGenerator            // Create Request Generator
    }
/************************************************************************/
// The Admin Resource deletgates permissions between Founders and Agents
pub resource Admin: Agent
{
        pub var status: Bool       // The current status of the Admin
        priv let grantee: Address

        init(_ admin: Address) {
            self.status  = true      // Default Admin status: True
            self.grantee = admin
        }

        // Used only when genreating a new Admin. Creates a Resource Generator for Negoiations.
        pub fun newRequestGenerator(): @RequestGenerator {
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied. No proper Admin Status")
                self.grantee == self.owner!.address       : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                self.status : "Account: ".concat(self.owner!.address.toString()).concat(" Access has been Frozen.") // status variable may be Depreicated // TODO check 
            }
            return <- create RequestGenerator(self.grantee) // return new Request
        }

        pub fun inviteAdmin(_ admin: Address) {     // Admin invite a new Admin
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                self.grantee == self.owner!.address : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                self.status                    : "You're no longer a have Access."
                DAAM_V11.creators[admin] == nil : "A Admin can not use the same address as an Creator."
                DAAM_V11.agents[admin] == nil   : "A Admin can not use the same address as an Agent."
                DAAM_V11.admins[admin] == nil   : "They're already sa DAAM_V11 Admin!!!"
                Profile.check(admin) : "You can't be a DAAM_V11 Admin without a Profile! Go make one Fool!!"
            }
            post { DAAM_V11.admins[admin] == false : "Illegal Operaion: inviteAdmin" }

            DAAM_V11.admins.insert(key: admin, false) // Admin account is setup but not active untill accepted.
            log("Sent Admin Invitation: ".concat(admin.toString()) )
            emit AdminInvited(admin: admin)                        
        }

        pub fun inviteAgent(_ agent: Address) {    // Admin ivites new Agent
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                self.grantee == self.owner!.address : "Account: ".concat(self.owner!.address.toString()).concat(" Permission Denied")
                self.status                 : "You're no longer a have Access."
                DAAM_V11.admins[agent] == nil   : "A Agent can not use the same address as an Admin."
                DAAM_V11.creators[agent] == nil : "A Agent can not use the same address as an Creator."
                DAAM_V11.agents[agent] == nil   : "They're already a DAAM_V11 Agent!!!"
                Profile.check(agent) : "You can't be a DAAM_V11 Admin without a Profile! Go make one Fool!!"
            }

            post {
                DAAM_V11.agents[agent] == false : "Illegal Operaion: invite Agent"
                DAAM_V11.admins[agent] == false : "Illegal Operaion: invite Agent"
            }

            DAAM_V11.admins.insert(key: agent, false) // Admin account is setup but not active untill accepted.
            DAAM_V11.agents.insert(key: agent, false )     // Agent account is setup but not active untill accepted.

            log("Sent Agent Invitation: ".concat(agent.toString()) )
            emit AgentInvited(agent: agent)         
        }

        pub fun inviteCreator(_ creator: Address) {    // Admin or Agent invite a new creator
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                   : "You're no longer a have Access."
                DAAM_V11.admins[creator]   == nil : "A Creator can not use the same address as an Admin."
                DAAM_V11.agents[creator]   == nil : "A Creator can not use the same address as an Agent."
                DAAM_V11.creators[creator] == nil : "They're already a DAAM_V11 Creator!!!"
                Profile.check(creator)        : "You can't be a DAAM_V11 Creator without a Profile! Go make one Fool!!"
            }
            post { DAAM_V11.isCreator(creator) == false : "Illegal Operaion: inviteCreator" }

            // If Creator is invited by Agent, attach Agent to Creator Info
            let creatorCap = getAccount(creator).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)
            let agencyCap  = getAccount(self.owner!.address).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)
            let creatorRoyalty = MetadataViews.Royalty(recepient: creatorCap, cut: 0.0, description: "Invited by ".concat(self.owner!.address.toString()) )
            let agencyRoyalty  = MetadataViews.Royalty(recepient: agencyCap, cut: 0.0, description: "Agency Invite")
            let creatorArg: {Address: MetadataViews.Royalty}  = {creator : creatorRoyalty}
            let agentArg  : {Address: MetadataViews.Royalty}? = 
                DAAM_V11.isAgent(self.owner!.address) != nil ? {self.owner!.address: agencyRoyalty} : {}
            let creatorInfo = CreatorInfo(
                creator: creatorArg,
                agent: agentArg ,
                status: false) // Store Creator status, false = invited, not yet answered
            DAAM_V11.creators.insert(key: creator, creatorInfo ) // Creator account is setup but not active untill accepted.

            log("Sent Creator Invitation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)      
        }

        pub fun inviteMinter(_ minter: Address) {   // Admin invites a new Minter (Key)
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status : "You're no longer a have Access."
            }
            post { DAAM_V11.minters[minter] == false : "Illegal Operaion: inviteCreator" }

            DAAM_V11.minters.insert(key: minter, false) // Minter Key is setup but not active untill accepted.
            log("Sent Minter Setup: ".concat(minter.toString()) )
            emit MinterSetup(minter: minter)      
        }

        pub fun removeAdmin(admin: Address) { // Two Admin to Remove Admin
            pre  {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status: "You're no longer a have Access."
            }

            let vote = 5 as Int // TODO change to x
            DAAM_V11.remove.insert(key: self.grantee, admin) // Append removal list
            if DAAM_V11.remove.length >= vote {                      // If votes is 3 or greater
                var counter: {Address: Int} = {} // {To Remove : Total Votes}
                // Talley Votes
                for a in DAAM_V11.remove.keys {
                    let remove = DAAM_V11.remove[a]! // get To Remove
                    // increment counter
                    if counter[remove] == nil {
                        counter.insert(key: remove, 1 as Int)
                    } else {
                        let value = counter[remove]! + 1 as Int
                        counter.insert(key: remove, value)
                    }
                }
                // Remove all with a vote of 3 or greater
                for c in counter.keys {
                    if counter[c]! >= vote {        // Does To Remove have enough votes to be removed
                        DAAM_V11.remove = {}           // Reset DAAM_V11.Remove
                        DAAM_V11.admins.remove(key: c) // Remove selected Admin
                        log("Removed Admin")
                        emit AdminRemoved(admin: admin)
                    }
                }                
            } // end if
        }

        pub fun removeAgent(agent: Address) { // Admin removes selected Agent by Address
            pre  {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                    : "You're no longer a have Access."
                DAAM_V11.agents.containsKey(agent) : "This is not a Agent Address."
            }
            post {
                !DAAM_V11.admins.containsKey(agent) : "Illegal operation: removeAgent"
                !DAAM_V11.agents.containsKey(agent) : "Illegal operation: removeAgent"
            } // Unreachable

            DAAM_V11.admins.remove(key: agent)    // Remove Agent from list
            DAAM_V11.agents.remove(key: agent)    // Remove Agent from list
            log("Removed Agent")
            emit AgentRemoved(agent: agent)
        }

        pub fun removeCreator(creator: Address) { // Admin removes selected Creator by Address
            pre {  
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                        : "You're no longer a have Access."
                DAAM_V11.creators.containsKey(creator) : "This is not a Creator address."
            }
            post { !DAAM_V11.creators.containsKey(creator) : "Illegal operation: removeCreator" } // Unreachable

            DAAM_V11.creators.remove(key: creator)    // Remove Creator from list
            DAAM_V11.metadataCap.remove(key: creator) // Remove Metadata Capability from list
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        pub fun removeMinter(minter: Address) { // Admin removes selected Agent by Address
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                      : "You're no longer a have Access."
                DAAM_V11.minters.containsKey(minter) : "This is not a Minter Address."
            }
            post { !DAAM_V11.minters.containsKey(minter) : "Illegal operation: removeAgent" } // Unreachable
            DAAM_V11.minters.remove(key: minter)    // Remove Agent from list
            log("Removed Minter")
            emit MinterRemoved(minter: minter)
        }

        // Admin can Change Agent status 
        pub fun changeAgentStatus(agent: Address, status: Bool) {
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                     : "You're no longer a have Access."
                DAAM_V11.agents.containsKey(agent)  : "Wrong Address. This is not an Agent."
                DAAM_V11.agents[agent] != status    : "Agent already has this Status."
            }
            post { DAAM_V11.agents[agent] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM_V11.agents[agent] = status // status changed
            log("Agent Status Changed")
            emit ChangeAgentStatus(agent: agent, status: status)
        }        

        // Admin or Agent can Change Creator status 
        pub fun changeCreatorStatus(creator: Address, status: Bool) {
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                         : "You're no longer a have Access."
                DAAM_V11.creators.containsKey(creator)  : "Wrong Address. This is not a Creator."
                DAAM_V11.isCreator(creator) != status    : "Agent already has this Status."
            }
            post { DAAM_V11.isCreator(creator) == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            let creatorInfo = &DAAM_V11.creators[creator]! as &CreatorInfo
            creatorInfo.status = status // status changed
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: status)
        }

        // Admin can Change Minter status 
        pub fun changeMinterStatus(minter: Address, status: Bool) {
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                       : "You're no longer a have Access."
                DAAM_V11.minters.containsKey(minter)  : "Wrong Address. This is not a Minter."
                DAAM_V11.minters[minter] != status    : "Minter already has this Status."
            }
            post { DAAM_V11.minters[minter] == status : "Illegal Operation: changeCreatorStatus" } // Unreachable

            DAAM_V11.minters[minter] = status // status changed
            log("Minter Status Changed")
            emit ChangeMinterStatus(minter: minter, status: status)
        }

        // Admin or Agent can change a Metadata status.
        pub fun changeMetadataStatus(mid: UInt64, status: Bool) {
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM_V11.copyright.containsKey(mid)      : "This is an Invalid MID"
            }            
            DAAM_V11.metadata[mid] = status // change to a new Metadata status
        }      

        // Admin or Agent can change a MIDs copyright status.
        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus) {
            pre {
                DAAM_V11.admins[self.owner!.address] == true  : "Permission Denied"
                self.grantee == self.owner!.address : "Permission Denied"
                self.status                          : "You're no longer a have Access."
                DAAM_V11.copyright.containsKey(mid)      : "This is an Invalid MID"
            }
            post { DAAM_V11.copyright[mid] == copyright  : "Illegal Operation: changeCopyright" } // Unreachable

            DAAM_V11.copyright[mid] = copyright    // Change to new copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }
	}
/************************************************************************/
// The Creator Resource (like Admin/Agent) is a permissions Resource. This allows the Creator
// to Create Metadata which inturn can be made in NFTs after Minting
    pub resource Creator {
        pub var agent: {UInt64: Address} // {MID: Agent Address} // preparation for V2
        access (contract) let grantee: Address

        init(_ creator: Address) {
            self.agent = {}
            self.grantee = creator
        }  // init Creators agent(s)

        // Used to create a Metadata Generator when initalizing Creator Storge
        pub fun newMetadataGenerator(): @MetadataGenerator {
            pre{
                self.grantee == self.owner!.address : "Permission Denied"
                DAAM_V11.creators.containsKey(self.grantee) : "You're not a Creator."
                DAAM_V11.isCreator(self.grantee) == true    : "Your Creator account is Frozen."
            }
            return <- create MetadataGenerator(self.grantee) // return Metadata Generator
        }

        // Used to create a Request Generator when initalizing Creator Storge
        pub fun newRequestGenerator(): @RequestGenerator {
            pre{
                self.grantee == self.owner!.address : "Permission Denied"
                DAAM_V11.creators.containsKey(self.grantee) : "You're not a Creator."
                DAAM_V11.isCreator(self.grantee) == true    : "Your Creator account is Frozen."
            }
            return <- create RequestGenerator(self.grantee) // return Request Generator
        } 
    }
/************************************************************************/
// mintNFT mints a new NFT and returns it.
// Note: new is defined by newly Minted. Age is not a consideration.
    pub resource Minter
    {
        priv let grantee: Address

        init(_ minter: Address) {
            self.grantee = minter
            DAAM_V11.minters.insert(key: minter, true) // Insert new Minter in minter list.
        }

        pub fun mintNFT(metadata: @Metadata): @DAAM_V11.NFT {
            pre{
                //metadata.edition.number <= metadata.edition.max || metadata.edition == 0 : "Internal Error: Mint Counter"
                DAAM_V11.isCreator(metadata.creatorInfo.creator.keys[0]) == true :
                    "Account: ".concat(metadata.creatorInfo.creator.keys[0].toString()).concat(" This is not our Creator.")
                DAAM_V11.isMinter(self.grantee) == true    : "Account: ".concat(self.grantee.toString()).concat(" Your Creator account is Frozen.")
                DAAM_V11.request.containsKey(metadata.mid) : "Invalid Request"
            }
            var isLast = false
            if metadata.edition.max != nil { 
                isLast = (metadata.edition.number <= metadata.edition.max!)
            }

            let mid = metadata.mid               // Get MID
            let nft <- create NFT(metadata: <- metadata, request: &DAAM_V11.request[mid] as &Request?) // Create NFT

            // Update Request, if last remove.
            if isLast {
                let request <- DAAM_V11.request.remove(key: mid)! // Get Request using MID
                destroy request       // if last destroy request, Request not needed. Counter has reached limit.
            } 
            self.newNFT(id: nft.id) // Mark NFT as new
            
            log("Minited NFT: ".concat(nft.id.toString()))
            emit MintedNFT(creator: nft.metadata.creatorInfo.creator.keys[0], id: nft.id)

            return <- nft  // return NFT
        }

        pub fun createMinterAccess(): @MinterAccess {
            return <- create MinterAccess(self.grantee)
        }

        // Removes token from 'new' list. 'new' is defines as newly Mited. Age is not a consideration.
        pub fun notNew(tokenID: UInt64) {
            pre  {
                self.grantee == self.owner!.address : "Permission Denied"
                DAAM_V11.newNFTs.contains(tokenID)      : "Token ID: ".concat(tokenID.toString()).concat(" is Not New.")
            }
            post { !DAAM_V11.newNFTs.contains(tokenID) : "Illegal Operation: notNew" } // Unreachable

            var counter: UInt64 = 0 as UInt64              // start the conter
            for nft in DAAM_V11.newNFTs {              // cycle through 'new' list
                if nft == tokenID {                // if Token ID is found
                    DAAM_V11.newNFTs.remove(at: counter) // remove from 'new' list
                    break
                } else {
                    counter = counter + 1          // increment counter
                }
            } // end for
        }

        // Add NFT to 'new' list
        priv fun newNFT(id: UInt64) {
            pre  { !DAAM_V11.newNFTs.contains(id) : "Token ID: ".concat(id.toString()).concat(" is already set to New.") }
            post { DAAM_V11.newNFTs.contains(id)  : "Illegal Operation: newNFT" }
                DAAM_V11.newNFTs.append(id)       // Append 'new' list
        }      
    }
/************************************************************************/
pub resource MinterAccess 
{
    pub let minter: Address
    init(_ minter : Address) { self.minter = minter }
    pub fun validate(): Bool { return DAAM_V11.minters[self.minter]==true ? true : false }
}
/************************************************************************/
    // Public DAAM_V11 functions

    // answerInvitation Functions:
    // True : invitation is accepted and invitation setting reset
    // False: invitation is declined and invitation setting reset

    // The Admin potential can accept (True) or deny (False)
    pub fun answerAdminInvite(newAdmin: AuthAccount, submit: Bool): @Admin? {
        pre {
            self.isAgent(newAdmin.address)   == nil : "Account: ".concat(newAdmin.address.toString()).concat(" A Admin can not use the same address as an Agent.")
            self.isCreator(newAdmin.address) == nil : "Account: ".concat(newAdmin.address.toString()).concat(" A Admin can not use the same address as an Creator.")
            self.isAdmin(newAdmin.address) == false : "Account: ".concat(newAdmin.address.toString()).concat(" You got no DAAM_V11 Admin invite.")
            Profile.check(newAdmin.address)  : "You can't be a DAAM_V11 Admin without a Profile first. Go make a Profile first."
        }

        if !submit { 
            DAAM_V11.admins.remove(key: newAdmin.address) // Release Admin
            return nil
        }  // Refused invitation. Return and end function
        
        // Invitation accepted at this point
        DAAM_V11.admins[newAdmin.address] = submit // Insert new Admin in admins list.
        log("Admin: ".concat(newAdmin.address.toString()).concat(" added to DAAM_V11") )
        emit NewAdmin(admin: newAdmin.address)
        return <- create Admin(newAdmin.address)      // Accepted and returning Admin Resource
    }

    // // The Agent potential can accept (True) or deny (False)
    pub fun answerAgentInvite(newAgent: AuthAccount, submit: Bool): @Admin{Agent}?
    {
        pre {
            self.isAdmin(newAgent.address)   == false : "Account: ".concat(newAgent.address.toString()).concat(" An Agent can not use the same address as an Admin.")
            self.isCreator(newAgent.address) == nil   : "Account: ".concat(newAgent.address.toString()).concat("A Agent can not use the same address as an Creator.")
            self.isAgent(newAgent.address)   == false : "Account: ".concat(newAgent.address.toString()).concat(" You got no DAAM_V11 Agent invite.")
            Profile.check(newAgent.address) : "You can't be a DAAM_V11 Agent without a Profile first. Go make a Profile first."
        }

        if !submit {                                  // Refused invitation. 
            DAAM_V11.admins.remove(key: newAgent.address) // Remove potential from Agent list
            DAAM_V11.agents.remove(key: newAgent.address) // Remove potential from Agent list
            return nil                                // Return and end function
        }
        // Invitation accepted at this point
        DAAM_V11.admins[newAgent.address] = submit        // Add Admin & set Status (True)
        DAAM_V11.agents[newAgent.address] = submit        // Add Agent & set Status (True)

        log("Agent: ".concat(newAgent.address.toString()).concat(" added to DAAM_V11") )
        emit NewAgent(agent: newAgent.address)
        return <- create Admin(newAgent.address)!             // Return Admin Resource as {Agent}
    }

    // // The Creator potential can accept (True) or deny (False)
    pub fun answerCreatorInvite(newCreator: AuthAccount, submit: Bool): @Creator? {
        pre {
            self.isAdmin(newCreator.address) == nil : "Account: ".concat(newCreator.address.toString()).concat(" A Creator can not use the same address as an Admin.")
            self.isAgent(newCreator.address) == nil : "Account: ".concat(newCreator.address.toString()).concat(" A Creator can not use the same address as an Agent.")
            self.isCreator(newCreator.address) == false : "Account: ".concat(newCreator.address.toString()).concat(" You got no DAAM_V11 Creator invite.")
            Profile.check(newCreator.address) : "You can't be a DAAM_V11 Creator without a Profile first. Go make a Profile first."
        }

        if !submit {                                       // Refused invitation.
            DAAM_V11.creators.remove(key: newCreator.address)  // Remove potential from Agent list
            return nil                                     // Return and end function
        }
        // Invitation accepted at this point
        let creatorInfo = &DAAM_V11.creators[newCreator.address]! as &CreatorInfo
        creatorInfo.status = submit         // Add Creator & set Status (True)
        log("Creator: ".concat(newCreator.address.toString()).concat(" added to DAAM_V11") )
        emit NewCreator(creator: newCreator.address)
        return <- create Creator(newCreator.address)!                         // Return Creator Resource
    }

    pub fun answerMinterInvite(newMinter: AuthAccount, submit: Bool): @Minter? {
        pre { self.isMinter(newMinter.address) == false : "Account: ".concat(newMinter.address.toString()).concat(" You do not have a Minter Invitation") }

        if !submit {                                      // Refused invitation. 
            DAAM_V11.minters.remove(key: newMinter.address) // Remove potential from Agent list
            return nil                                    // Return and end function
        }
        // Invitation accepted at this point
        log("Minter: ".concat(newMinter.address.toString()) )
        emit NewMinter(minter: newMinter.address)
        return <- create Minter(newMinter.address)             // Return Minter (Key) Resource
    }
    
    // Create an new Collection to store NFTs
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        post { result.getIDs().length == 0: "The created collection must be empty!" }
        return <- create Collection() // Return Collection Resource
    }

    // Create an new Collection to store NFTs
    pub fun createDAAM_V11Collection(): @DAAM_V11.Collection {
        post { result.getIDs().length == 0: "The created DAAM_V11 collection must be empty!" }
        return <- create DAAM_V11.Collection() // Return Collection Resource
    }

    // Return list of Creators
    pub fun getCreators(): [Address] {
        var clist: [Address] = []
        for creator in self.creators.keys {
            clist.append(creator)
        }
        return clist
    }

    // Return Copyright Status. nil = non-existent MID
    pub fun getCopyright(mid: UInt64): CopyrightStatus? { 
        return self.copyright[mid]
    }

    pub fun isNFTNew(id: UInt64): Bool {  // Return True if new
        return self.newNFTs.contains(id)   // Note: 'New' is defined a newly minted. Age is not a consideration. 
    }

    pub fun isAdmin(_ admin: Address): Bool? { // Returns Admin Status
        if self.admins[admin] == nil { return nil }
        let agent = (self.agents[admin] == true) ? true : false
        return self.admins[admin]! && !agent
    }

    pub fun isAgent(_ agent: Address): Bool? { // Returns Agent status
        return self.agents[agent] // nil = not an agent, false = invited to be am agent, true = is an agent
    }

    pub fun isMinter(_ minter: Address): Bool? { // Returns Agent status
        return self.minters[minter] // nil = not an agent, false = invited to be am agent, true = is an agent
    }

    pub fun isCreator(_ creator: Address): Bool? { // Returns Creator status
        if self.creators[creator] == nil { return nil }
        let creatorInfo = &DAAM_V11.creators[creator]! as &CreatorInfo
        return creatorInfo.status // nil = not a creator, false = invited to be a creator, true = is a creator
    }
/************************************************************************/
// Init DAAM_V11 Contract variables
    
    init(founders: {Address:UFix64}, defaultAdmins: [Address])
    {
        //let founders: {Address:UFix64} = {0x1beecc6fef95b62e: 0.6, 0x1beecc6fef95b62e: 0.4}
        //let defaultAdmins: [Address] = [0x0f7025fa05b578e3, 0x1beecc6fef95b62e]
        // Paths
        self.collectionPublicPath  = /public/DAAM_V11_Collection
        self.collectionStoragePath = /storage/DAAM_V11_Collection
        self.metadataPublicPath    = /public/DAAM_V11_SubmitNFT
        self.metadataStoragePath   = /storage/DAAM_V11_SubmitNFT
        self.adminPrivatePath      = /private/DAAM_V11_Admin
        self.adminStoragePath      = /storage/DAAM_V11_Admin
        self.minterPrivatePath     = /private/DAAM_V11_Minter
        self.minterStoragePath     = /storage/DAAM_V11_Minter
        self.creatorPrivatePath    = /private/DAAM_V11_Creator
        self.creatorStoragePath    = /storage/DAAM_V11_Creator
        self.requestPrivatePath    = /private/DAAM_V11_Request
        self.requestStoragePath    = /storage/DAAM_V11_Request

        // Setup Up Founders
        var royalty_list: [MetadataViews.Royalty] = []
        for founder in founders.keys {
            royalty_list.append(
                MetadataViews.Royalty(recepient: getAccount(founder).getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver), // TODO remove /public/fusdReceiver
                cut: founders[founder]!,
                description: "Founder: ".concat(founder.toString()).concat("Percentage: ").concat(founders[founder]!.toString())
                ) // end royalty_list
            ) // end append
        }
        self.agency = MetadataViews.Royalties(royalty_list)

        // Initialize variables
        self.admins    = {}
        self.remove    = {}
        self.request  <- {}
        self.copyright = {}
        self.agents    = {} 
        self.creators  = {}
        self.minters   = {}
        self.metadata  = {}
        self.metadataCap = {}
        self.newNFTs   = []
        // Counter varibbles
        self.totalSupply         = 0  // Initialize the total supply of NFTs
        self.metadataCounterID   = 0  // Incremental Serial Number for the MetadataGenerator

        // Setup Up Default Admins
        for admin in defaultAdmins { self.admins.insert(key: admin, false) }
        
        emit ContractInitialized()
	}
}
 