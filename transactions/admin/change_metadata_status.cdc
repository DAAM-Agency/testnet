// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
    let admin  : &DAAM_V14.Admin{DAAM_V14.Agent}
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
    let admin  : &DAAM_V15.Admin{DAAM_V15.Agent}
>>>>>>> DAAM_V15
    let mid    : UInt64
    let status : Bool

    prepare(agent: AuthAccount) {
<<<<<<< HEAD
        self.admin  = agent.borrow<&DAAM_V14.Admin{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)!
=======
        self.admin  = agent.borrow<&DAAM_V15.Admin{DAAM_V15.Agent}>(from: DAAM_V15.adminStoragePath)!
>>>>>>> DAAM_V15
        self.mid    = mid
        self.status = status
    }

    execute {
        self.admin.changeMetadataStatus(mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
