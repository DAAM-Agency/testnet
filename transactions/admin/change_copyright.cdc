// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM_V23.CopyrightStatus.FRAUD
1 as int 8 = DAAM_V23.CopyrightStatus.CLAIM
2 as int 8 = DAAM_V23.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM_V23.CopyrightStatus.VERIFIED
4 as int 8 = DAAM_V23.CopyrightStatus.INCLUDED
*/

import DAAM_V23 from 0xa4ad5ea5c0bd2fba
    
transaction(creator: Address, mid: UInt64, copyright: UInt8) {
    let cr     : DAAM_V23.CopyrightStatus
<<<<<<< HEAD
    let admin  : &{DAAM_V23.Agent}
=======
    let admin  : &DAAM.Admin{DAAM.Agent}
>>>>>>> tomerge
    let mid    : UInt64
    let creator: Address

    prepare(agent: AuthAccount) {
        self.cr      = DAAM_V23.CopyrightStatus(rawValue: copyright)!                             // init copyright
<<<<<<< HEAD
        self.admin   = agent.borrow<&{DAAM_V23.Agent}>(from: DAAM_V23.adminStoragePath)! // init admin
=======
        self.admin   = agent.borrow<&{DAAM.Agent}>(from: DAAM_V23.adminStoragePath)! // init admin
>>>>>>> tomerge
        self.mid     = mid 
        self.creator = creator                                                        // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM_V23.CopyrightStatus length

    execute {
        self.admin.changeCopyright(creator: self.creator, mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}