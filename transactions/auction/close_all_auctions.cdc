// close_all_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_V8 from 0x01837e15023c9249

// Returns all Sellers and their auction IDs of auctions that have ended
pub fun getClosedAuctions(): {Address: [UInt64]} {
    let currentAuctions = AuctionHouse_V8.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
    var list: {Address: [UInt64]} = {}

    for seller in currentAuctions.keys {
        let AuctionHouse_V8 = getAccount(seller).getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>(AuctionHouse_V8.auctionPublicPath).borrow()!
        let auctions = currentAuctions[seller]!

        for aid in auctions {
            let auctionRef = AuctionHouse_V8.item(aid) as &AuctionHouse_V8.Auction{AuctionHouse_V8.AuctionPublic}?
            if auctionRef!.getStatus() == false {
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

transaction() {
    let AuctionHouse_V8 : [&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}]
   
    prepare(signer: AuthAccount) {
        self.AuctionHouse_V8 = []
        let list = getClosedAuctions()
        for l in list.keys {
            self.AuctionHouse_V8.append(
                getAccount(l).getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>(AuctionHouse_V8.auctionPublicPath).borrow()! )
        }
    }

    execute {
        for seller in self.AuctionHouse_V8 { seller.closeAuctions() }
        log("Auction(s) Closed")
    }
}
