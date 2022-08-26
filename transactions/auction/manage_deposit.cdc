// manage_auction.cdc
// Used to Approve / Disapprove an Auction made by an Agent

import AuctionHouse_V16 from 0x01837e15023c9249

transaction(aid: UInt64, approve: Bool)
{
    let aid          : UInt64
    let approve      : Bool
    let auctionHouse : &AuctionHouse_V16.AuctionWallet
    
    prepare(auctioneer: AuthAccount) {
        self.aid          = aid
        self.approve      = approve
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V16.AuctionWallet>(from: AuctionHouse_V16.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.agentAuction(auctionID: self.aid, approve: self.approve)
    }
}
 