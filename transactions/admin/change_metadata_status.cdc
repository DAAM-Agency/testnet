// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, mid: UInt64, status: Bool)
{
    let admin  : &DAAM_V22.Admin{DAAM_V22.Agent}
    let mid    : UInt64
    let status : Bool
    let creator: Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V22.Admin{DAAM_V22.Agent}>(from: DAAM_V22.V22.adminStoragePath)!
        self.mid     = mid
        self.status  = status
        self.creator = creator
    }

    execute {
        self.admin.changeMetadataStatus(creator: self.creator, mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
