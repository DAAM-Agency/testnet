// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM_V11.CopyrightStatus.FRAUD
1 as int 8 = DAAM_V11.CopyrightStatus.CLAIM
2 as int 8 = DAAM_V11.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM_V11.CopyrightStatus.VERIFIED
4 as int 8 = DAAM_V11.CopyrightStatus.INCLUDED
*/

import DAAM_V11 from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: UInt8) {
    let cr    : DAAM_V11.CopyrightStatus
    let admin : &{DAAM_V11.Agent}
    let mid   : UInt64

    prepare(agent: AuthAccount) {
        self.cr = DAAM_V11.CopyrightStatus(copyright)!                             // init copyright
        self.admin = agent.borrow<&{DAAM_V11.Agent}>(from: DAAM_V11.adminStoragePath)! // init admin
        self.mid = mid                                                         // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM_V11.CopyrightStatus length

    execute {
        self.admin.changeCopyright(mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}