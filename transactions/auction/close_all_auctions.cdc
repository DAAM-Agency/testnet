// close_all_auctions.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

<<<<<<< HEAD
import AuctionHouse_V16 from 0x01837e15023c9249
=======
import AuctionHouse_V16 from 0x01837e15023c9249
>>>>>>> tomerge

// Returns all Sellers and their auction IDs of auctions that have ended
pub fun getClosedAuctions(): {Address: [UInt64]} {
    let currentAuctions = AuctionHouse_V16.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
    var list: {Address: [UInt64]} = {}

    for seller in currentAuctions.keys {
        let auctionHouse = getAccount(seller).getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>(AuctionHouse_V16.auctionPublicPath).borrow()!
        let auctions = currentAuctions[seller]!

        for aid in auctions {
            let auctionRef = auctionHouse.item(aid) as &AuctionHouse_V16.Auction{AuctionHouse_V16.AuctionPublic}?
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
    let auctionHouse : [&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}]
   
    prepare(signer: AuthAccount) {
        self.auctionHouse = []
        let list = getClosedAuctions()
        for l in list.keys {
            self.auctionHouse.append(
                getAccount(l).getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>(AuctionHouse_V16.auctionPublicPath).borrow()! )
        }
    }

    execute {
        for seller in self.auctionHouse { seller.closeAuctions() }
        log("Auction(s) Closed")
    }
}
