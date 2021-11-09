// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID

import DAAM from 0xfd43f9148d4b725d
    
transaction(mid: UInt64, copyright: Int)
{
    let cr    : DAAM.CopyrightStatus
    let admin : &{DAAM.Agent}
    let mid   : UInt64

    prepare(agent: AuthAccount) {
        switch(copyright) {
            case 0: self.cr = DAAM.CopyrightStatus.FRAUD
            case 1: self.cr = DAAM.CopyrightStatus.CLAIM
            case 2: self.cr = DAAM.CopyrightStatus.UNVERIFIED
            case 3: self.cr = DAAM.CopyrightStatus.VERIFIED
            case 4: self.cr = DAAM.CopyrightStatus.INCLUDED
            default: return
        } // init cr
        self.admin = agent.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)! // init admin
        self.mid = mid                                                         // init mid
    }

    execute {
        self.admin.changeCopyright(mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}