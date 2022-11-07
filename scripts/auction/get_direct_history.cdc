// get_direct.history.cdc
// Return all (nil) or spcific history

import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM_Mainnet          from 0xfd43f9148d4b725d
import AuctionHouse_Mainnet  from 0x045a1763c93006ca

pub struct DirectHistory {
    pub let mid : UInt64
	pub let name: String
	pub let file: {String: MetadataViews.Media}
	pub let creator: Address
	pub let royalty: MetadataViews.Royalties
	pub var collection : [DAAM_Mainnet.NFTCollectionDisplay] // contains feature
	pub var saleHistory: {UInt64: AuctionHouse_Mainnet.SaleHistory}//[AuctionHouse_Mainnet.SaleHistoryEntry]

    init(creator:Address, mid: UInt64) {
        let metadataRef = getAccount(creator)
			.getCapability<&DAAMDAAM_Mainnet_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath).borrow()!
		let metadata = metadataRef.viewMetadata(mid: mid)!
		
		self.mid  = metadata.mid!
        self.name = metadata.edition.name!
        self.file = metadataRef.getFile(mid: self.mid)!
        self.creator = metadata.creatorInfo!.creator!
		self.royalty = DAAM_Mainnet.getRoyalties(mid: self.mid)

        let collectionRef = getAccount(creator)
			.getCapability<&{DAAM_Mainnet.CollectionPublic}>(DAAM_Mainnet.collectionPublicPath).borrow()!    
        let collections   = collectionRef.getCollection()

        self.collection  = []
        for c in collections {
            if c.mid.containsKey(self.mid) {
				self.collection.append(c) // adding collection
			}
        }

        let history = AuctionHouse_Mainnet.getHistory(mid: self.mid)!
		let saleHistory = history[self.mid]!
		self.saleHistory = saleHistory
    }
}

pub fun main(creator: Address, mid: UInt64): DirectHistory { // {Creator { MID : {TokenID:SaleHistory} } }
	return DirectHistory(creator: creator, mid: mid)
}