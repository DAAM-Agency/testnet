// bargin.cdc
// Used for Admin / Agent to respond to a bargin neogation

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, percentage: UFix64)
{
    let admin      : &DAAM_V23.Admin{DAAM_V23.Agent}
    let mid        : UInt64
    let percentage : UFix64
    let creator    : Address

    prepare(agent: AuthAccount) {
        self.admin      = agent.borrow<&DAAM_V23.Admin{DAAM_V23.Agent}>(from: DAAM_V23.adminStoragePath)!
        self.mid        = mid
        self.percentage = percentage
        self.creator    = creator
    }

    execute {
        self.admin.bargin(creator: self.creator, mid: self.mid, percentage: self.percentage)
    }
}