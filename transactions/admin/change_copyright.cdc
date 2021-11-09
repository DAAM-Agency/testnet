// change_copyright.cdc

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

    pre { DAAM.isAdmin(agent.address) || DAAM.isAgent(agent.address) } // Verify Access

    execute {
        self.admin.changeCopyright(mid: self.mid, copyright: self.cr)
        log("Copyright Changed")
    }
}