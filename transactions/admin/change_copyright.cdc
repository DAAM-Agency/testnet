// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM_V13.CopyrightStatus.FRAUD
1 as int 8 = DAAM_V13.CopyrightStatus.CLAIM
2 as int 8 = DAAM_V13.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM_V13.CopyrightStatus.VERIFIED
4 as int 8 = DAAM_V13.CopyrightStatus.INCLUDED
*/

import DAAM_V13 from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: UInt8) {
    let cr    : DAAM_V13.CopyrightStatus
    let admin : &{DAAM_V13.Agent}
    let mid   : UInt64

    prepare(agent: AuthAccount) {
        self.cr = DAAM_V13.CopyrightStatus(copyright)!                             // init copyright
        self.admin = agent.borrow<&{DAAM_V13.Agent}>(from: DAAM_V13.adminStoragePath)! // init admin
        self.mid = mid                                                         // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM_V13.CopyrightStatus length

    execute {
        self.admin.changeCopyright(mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}