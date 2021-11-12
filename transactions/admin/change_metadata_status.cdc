// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
<<<<<<< HEAD
    let admin : &DAAM_V5.Admin
    let mid   : UInt64
    let status: Bool

    prepare(acct: AuthAccount) {
        self.admin  = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
=======
    let admin  : &DAAM_V5.Admin{DAAM_V5.Agent}
    let mid    : UInt64
    let status : Bool

    prepare(agent: AuthAccount) {
        self.admin  = agent.borrow<&DAAM_V5.Admin{DAAM_V5.Agent}>(from: DAAM_V5.adminStoragePath)!
>>>>>>> merge_dev
        self.mid    = mid
        self.status = status
    }

    execute {
        self.admin.changeMetadataStatus(mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
