// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
    let admin  : &DAAM_V10.Admin{DAAM_V10.Agent}
    let mid    : UInt64
    let status : Bool

    prepare(agent: AuthAccount) {
        self.admin  = agent.borrow<&DAAM_V10.Admin{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)!
        self.mid    = mid
        self.status = status
    }

    execute {
        self.admin.changeMetadataStatus(mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
