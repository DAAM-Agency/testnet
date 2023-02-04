// creator_bargin.cdc
// Used for Creator to respond to a bargin neogation

import DAAM from 0x7db4d10c78bad30a

transaction(mid: UInt64, percentage: UFix64)
{
    let creator    : &DAAM.Creator
    let mid        : UInt64
    let percentage : UFix64

    prepare(creator: AuthAccount) {
        self.creator    = creator.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
        self.mid        = mid
        self.percentage = percentage
    }

    execute {
        self.creator.bargin(mid: self.mid, percentage: self.percentage)
    }
}
