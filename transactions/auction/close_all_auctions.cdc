// close_all_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import AuctionHouse_V15 from 0x045a1763c93006ca

// Returns all Sellers and their auction IDs of auctions that have ended
pub fun getClosedAuctions(): {Address: [UInt64]} {
    let currentAuctions = AuctionHouse_V15.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
    var list: {Address: [UInt64]} = {}

    for seller in currentAuctions.keys {
        let auctionHouse = getAccount(seller).getCapability<&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}>(AuctionHouse_V15.auctionPublicPath).borrow()!
        let auctions = currentAuctions[seller]!

        for aid in auctions {
            let auctionRef = auctionHouse.item(aid) as &AuctionHouse_V15.Auction{AuctionHouse_V15.AuctionPublic}?
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
    let auctionHouse : [&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}]
   
    prepare(signer: AuthAccount) {
        self.auctionHouse = []
        let list = getClosedAuctions()
        for l in list.keys {
            self.auctionHouse.append(
                getAccount(l).getCapability<&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}>(AuctionHouse_V15.auctionPublicPath).borrow()! )
        }
    }

    execute {
        for seller in self.auctionHouse { seller.closeAuctions() }
        log("Auction(s) Closed")
    }
}
