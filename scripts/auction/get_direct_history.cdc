// get_direct.history.cdc
// Return all (nil) or spcific history

import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V23         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V16 from 0x01837e15023c9249

pub struct DirectHistory {
    pub let mid : UInt64
	pub let name: String
	pub let file: {String: MetadataViews.Media}
	pub let creator: Address
	pub let royalty: MetadataViews.Royalties
	pub var collection : [DAAM_V23.NFTCollectionDisplay] // contains feature
	pub var saleHistory: {UInt64: AuctionHouse_V16.SaleHistory}//[AuctionHouse_V16.SaleHistoryEntry]

    init(creator:Address, mid: UInt64) {
        let metadataRef = getAccount(creator)
			.getCapability<&DAAM_V23.MetadataGenerator{DAAM_V23.MetadataGeneratorPublic}>(DAAM_V23.metadataPublicPath).borrow()!
		let metadata = metadataRef.viewMetadata(mid: mid)!
		
		self.mid  = metadata.mid!
        self.name = metadata.edition.name!
        self.file = metadataRef.getFile(mid: self.mid)
        self.creator = metadata.creatorInfo!.creator!
		self.royalty = DAAM_V23.getRoyalties(mid: self.mid)

        let collectionRef = getAccount(creator)
			.getCapability<&DAAM_V23.Collection{DAAM_V23.CollectionPublic}>(DAAM_V23.collectionPublicPath).borrow()!    
        let collections   = collectionRef.getCollection()

        self.collection  = []
        for c in collections {
            if c.mid.containsKey(self.mid) {
				self.collection.append(c) // adding collection
			}
        }

        let history = AuctionHouse_V16.getHistory(mid: self.mid)!
		let saleHistory = history[self.mid]!
		self.saleHistory = saleHistory
    }
}

pub fun main(creator: Address, mid: UInt64): DirectHistory { // {Creator { MID : {TokenID:SaleHistory} } }
	return DirectHistory(creator: creator, mid: mid)
}