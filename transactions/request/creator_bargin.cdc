// creator_bargin.cdc
// Used for Creator to respond to a bargin neogation

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64)
{
    let creator    : &DAAM_V23.Creator
    let mid        : UInt64
    let percentage : UFix64

    prepare(creator: AuthAccount) {
        self.creator    = creator.borrow<&DAAM_V23.Creator>(from: DAAM_V23.creatorStoragePath)!
        self.mid        = mid
        self.percentage = percentage
    }

    execute {
        self.creator.bargin(mid: self.mid, percentage: self.percentage)
    }
}
