// get_auctions_with_status.cdc
// Return all auctions that match the argument status
// status meaning: nil = not started, true = on-going auction, false = auction ended

import AuctionHouse_V17 from 0x045a1763c93006ca

pub fun main(status: Bool?): {Address: [UInt64]}  {    
    let currentAuctions = AuctionHouse_V17.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
    var list: {Address: [UInt64]} = {}

    for seller in currentAuctions.keys {
        let auctionHouse = getAccount(seller).getCapability<&AuctionHouse_V17.AuctionWallet{AuctionHouse_V17.AuctionWalletPublic}>(AuctionHouse_V17.auctionPublicPath).borrow()!
        let auctions = currentAuctions[seller]!

        for aid in auctions {
            let auctionRef = auctionHouse.item(aid) as &AuctionHouse_V17.Auction{AuctionHouse_V17.AuctionPublic}?
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