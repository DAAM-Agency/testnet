// bargin.cdc
// Used for Admin / Agent to respond to a bargin neogation

//import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, percentage: UFix64)
{
    let admin      : &DAAM.Admin{DAAM.Agent}
    let mid        : UInt64
    let percentage : UFix64
    let creator    : Address

    prepare(agent: AuthAccount) {
        self.admin      = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.mid        = mid
        self.percentage = percentage
        self.creator    = creator
    }

    execute {
        self.admin.bargin(creator: self.creator, mid: self.mid, percentage: self.percentage)
    }
}