// bargin.cdc
// Used for Admin / Agent to respond to a bargin neogation
import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

transaction(mid: UInt64, royalty: UFix64)
{
    let admin   : &DAAM.Admin{DAAM.Agent}
    let mid     : UInt64
    let royalty : UFix64

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.mid = mid
        self.royalty = royalty
    }

    execute {
        self.admin.bargin(mid: self.mid, royalty: self.royalty)
        log("Creator Invited")
    }
}
