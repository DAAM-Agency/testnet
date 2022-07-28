// get_creator_history.cdc
// Return all (nil) or spcific creator history

import DAAM_V20         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V14 from 0x045a1763c93006ca

pub fun main(creator: Address): {UInt64 : {UInt64: AuctionHouse_V14.SaleHistory}} { // {MID : {TokenID:SaleHistory} }
    let creatorMIDs = DAAM_V20.getCreatorMIDs(creator: creator)
    var history: {UInt64 : {UInt64:AuctionHouse_V14.SaleHistory} } = {}
    for mid in creatorMIDs! {
        let historyEntry = AuctionHouse_V14.getHistory(mid: mid)
        if historyEntry == nil { continue }
        history.insert(key: mid, historyEntry![mid]! )
    }
    return history
}