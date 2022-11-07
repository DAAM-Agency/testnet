// creator_bargin.cdc
// Used for Creator to respond to a bargin neogation

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64)
{
    let creator    : &DAAMDAAM_Mainnet_Mainnet.Creator
    let mid        : UInt64
    let percentage : UFix64

    prepare(creator: AuthAccount) {
        self.creator    = creator.borrow<&DAAMDAAM_Mainnet_Mainnet.Creator>(from: DAAM_Mainnet.creatorStoragePath)!
        self.mid        = mid
        self.percentage = percentage
    }

    execute {
        self.creator.bargin(mid: self.mid, percentage: self.percentage)
    }
}
