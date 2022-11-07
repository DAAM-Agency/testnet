// get_creator_history.cdc
// Return all (nil) or spcific creator history

import DAAM_Mainnet         from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

pub fun main(creator: Address): {UInt64 : {UInt64: AuctionHouse.SaleHistory}} { // {MID : {TokenID:SaleHistory} }
    let creatorMIDs = DAAM_Mainnet.getCreatorMIDs(creator: creator)
    var history: {UInt64 : {UInt64:AuctionHouse.SaleHistory} } = {}
    for mid in creatorMIDs! {
        let historyEntry = AuctionHouse.getHistory(mid: mid)
        if historyEntry == nil { continue }
        history.insert(key: mid, historyEntry![mid]! )
    }
    return history
}