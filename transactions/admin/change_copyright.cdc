// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM.CopyrightStatus.FRAUD
1 as int 8 = DAAM.CopyrightStatus.CLAIM
2 as int 8 = DAAM.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM.CopyrightStatus.VERIFIED
4 as int 8 = DAAM.CopyrightStatus.INCLUDED
*/

import DAAM from 0x7db4d10c78bad30a
    
transaction(creator: Address, mid: UInt64, copyright: UInt8) {
    let cr     : DAAM.CopyrightStatus
    let admin  : &DAAM.Admin{DAAM.Agent}
    let mid    : UInt64
    let creator: Address

    prepare(agent: AuthAccount) {
        self.cr      = DAAM.CopyrightStatus(rawValue: copyright)!                             // init copyright
        self.admin   = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)! // init admin
        self.mid     = mid 
        self.creator = creator                                                        // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM.CopyrightStatus length

    execute {
        self.admin.changeCopyright(creator: self.creator, mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}