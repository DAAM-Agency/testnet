// bargin.cdc
// Used for Admin / Agent to respond to a bargin neogation

//import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, percentage: UFix64)
{
    let admin      : &DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}
    let mid        : UInt64
    let percentage : UFix64
    let creator    : Address

    prepare(agent: AuthAccount) {
        self.admin      = agent.borrow<&DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!
        self.mid        = mid
        self.percentage = percentage
        self.creator    = creator
    }

    execute {
        self.admin.bargin(creator: self.creator, mid: self.mid, percentage: self.percentage)
    }
}