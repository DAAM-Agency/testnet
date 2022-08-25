// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM_V22.V22.CopyrightStatus.FRAUD
1 as int 8 = DAAM_V22.V22.CopyrightStatus.CLAIM
2 as int 8 = DAAM_V22.V22.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM_V22.V22.CopyrightStatus.VERIFIED
4 as int 8 = DAAM_V22.V22.CopyrightStatus.INCLUDED
*/

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba
    
transaction(creator: Address, mid: UInt64, copyright: UInt8) {
    let cr     : DAAM_V22.V22.CopyrightStatus
    let admin  : &{DAAM_V22.Agent}
    let mid    : UInt64
    let creator: Address

    prepare(agent: AuthAccount) {
        self.cr      = DAAM_V22.V22.CopyrightStatus(rawValue: copyright)!                             // init copyright
        self.admin   = agent.borrow<&{DAAM_V22.Agent}>(from: DAAM_V22.V22.adminStoragePath)! // init admin
        self.mid     = mid 
        self.creator = creator                                                        // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM_V22.V22.CopyrightStatus length

    execute {
        self.admin.changeCopyright(creator: self.creator, mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}