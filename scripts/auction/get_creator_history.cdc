// get_creator_history.cdc
// Return all (nil) or spcific creator history

import DAAM_Mainnet         from 0xfd43f9148d4b725d
import AuctionHouse_Mainnet from 0x045a1763c93006ca

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