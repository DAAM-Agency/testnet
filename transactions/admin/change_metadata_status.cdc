// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

import DAAM from 0x7db4d10c78bad30a

transaction(creator: Address, mid: UInt64, status: Bool)
{
    let admin  : &DAAM.Admin{DAAM.Agent}
    let mid    : UInt64
    let status : Bool
    let creator: Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.mid     = mid
        self.status  = status
        self.creator = creator
    }

    execute {
        self.admin.changeMetadataStatus(creator: self.creator, mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
