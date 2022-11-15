// get_creator_history.cdc
// Return all (nil) or spcific creator history

import DAAM_Mainnet         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet from 0x01837e15023c9249

pub fun main(creator: Address): {UInt64 : {UInt64: AuctionHouse_Mainnet.SaleHistory}} { // {MID : {TokenID:SaleHistory} }
    let creatorMIDs = DAAM_Mainnet.getCreatorMIDs(creator: creator)
    var history: {UInt64 : {UInt64:AuctionHouse_Mainnet.SaleHistory} } = {}
    for mid in creatorMIDs! {
        let historyEntry = AuctionHouse_Mainnet.getHistory(mid: mid)
        if historyEntry == nil { continue }
        history.insert(key: mid, historyEntry![mid]! )
    }
    return history
}