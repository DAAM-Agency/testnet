// get_auctions_with_status.cdc
// Return all auctions that match the argument status
// status meaning: nil = not started, true = on-going auction, false = auction ended

import AuctionHouse_V8  from 0x01837e15023c9249

pub fun main(status: Bool?): {Address: [UInt64]}  {    
    let currentAuctions = AuctionHouse_V8.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
    var list: {Address: [UInt64]} = {}

    for seller in currentAuctions.keys {
        let AuctionHouse_V8 = getAccount(seller).getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>(AuctionHouse_V8.auctionPublicPath).borrow()!
        let auctions = currentAuctions[seller]!

        for aid in auctions {
            let auctionRef = AuctionHouse_V8.item(aid) as &AuctionHouse_V8.Auction{AuctionHouse_V8.AuctionPublic}?
            if auctionRef!.getStatus() == status {
                if list.containsKey(seller) {
                    assert(!list[seller]!.contains(aid), message: "Already contains aid" )
                    list[seller]!.append(aid)
                } else {
                    list.insert(key: seller, [aid])
                }
            }// Got Status
        }
    }

    return list
}