// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM_V14.CopyrightStatus.FRAUD
1 as int 8 = DAAM_V14.CopyrightStatus.CLAIM
2 as int 8 = DAAM_V14.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM_V14.CopyrightStatus.VERIFIED
4 as int 8 = DAAM_V14.CopyrightStatus.INCLUDED
*/

import DAAM_V14 from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: UInt8) {
    let cr    : DAAM_V14.CopyrightStatus
    let admin : &{DAAM_V14.Agent}
    let mid   : UInt64

    prepare(agent: AuthAccount) {
        self.cr = DAAM_V14.CopyrightStatus(copyright)!                             // init copyright
        self.admin = agent.borrow<&{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)! // init admin
        self.mid = mid                                                         // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM_V14.CopyrightStatus length

    execute {
        self.admin.changeCopyright(mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}