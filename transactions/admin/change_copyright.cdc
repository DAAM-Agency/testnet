// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM.CopyrightStatus.FRAUD
1 as int 8 = DAAM.CopyrightStatus.CLAIM
2 as int 8 = DAAM.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM.CopyrightStatus.VERIFIED
4 as int 8 = DAAM.CopyrightStatus.INCLUDED
*/

import DAAM from 0xfd43f9148d4b725d
    
transaction(mid: UInt64, copyright: UInt8) {
    let cr    : DAAM.CopyrightStatus
    let admin : &{DAAM.Agent}
    let mid   : UInt64

    prepare(agent: AuthAccount) {
        self.cr = DAAM.CopyrightStatus(copyright)!                             // init copyright
        self.admin = agent.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)! // init admin
        self.mid = mid                                                         // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM.CopyrightStatus length

    execute {
        self.admin.changeCopyright(mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}