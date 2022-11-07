// change_metadata_status.cdc
// Used for Admin / Agents to Approve/Disapprove Metadata via MID. True = Approved, False = Disapproved

import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction(creator: Address, mid: UInt64, status: Bool)
{
    let admin  : &DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}
    let mid    : UInt64
    let status : Bool
    let creator: Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!
        self.mid     = mid
        self.status  = status
        self.creator = creator
    }

    execute {
        self.admin.changeMetadataStatus(creator: self.creator, mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
