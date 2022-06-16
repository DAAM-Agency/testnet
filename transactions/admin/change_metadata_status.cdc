// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
    let admin  : &DAAM_V10.Admin{DAAM_V10.Agent}
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
    let admin  : &DAAM_V14.Admin{DAAM_V14.Agent}
>>>>>>> DAAM_V14
    let mid    : UInt64
    let status : Bool

    prepare(agent: AuthAccount) {
<<<<<<< HEAD
        self.admin  = agent.borrow<&DAAM_V10.Admin{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)!
=======
        self.admin  = agent.borrow<&DAAM_V14.Admin{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)!
>>>>>>> DAAM_V14
        self.mid    = mid
        self.status = status
    }

    execute {
        self.admin.changeMetadataStatus(mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
