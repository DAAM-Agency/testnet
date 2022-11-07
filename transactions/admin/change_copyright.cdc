// change_copyright.cdc
// Used for Admin / Agents to change Copyright status of MID
/*
0 as int 8 = DAAM_Mainnet.CopyrightStatus.FRAUD
1 as int 8 = DAAM_Mainnet.CopyrightStatus.CLAIM
2 as int 8 = DAAM_Mainnet.CopyrightStatus.UNVERIFIED
3 as int 8 = DAAM_Mainnet.CopyrightStatus.VERIFIED
4 as int 8 = DAAM_Mainnet.CopyrightStatus.INCLUDED
*/

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba
    
transaction(creator: Address, mid: UInt64, copyright: UInt8) {
    let cr     : DAAM_Mainnet.CopyrightStatus
    let admin  : &DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}
    let mid    : UInt64
    let creator: Address

    prepare(agent: AuthAccount) {
        self.cr      = DAAM_Mainnet.CopyrightStatus(rawValue: copyright)!                             // init copyright
        self.admin   = agent.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)! // init admin
        self.mid     = mid 
        self.creator = creator                                                        // init mid
    }

    pre { copyright < 5 : "Copyright: Invalid Entry" } // Verify copyright is within DAAM_Mainnet.CopyrightStatus length

    execute {
        self.admin.changeCopyright(creator: self.creator, mid: self.mid, copyright: self.cr)  // Change Copyright status
        log("Copyright Changed")
    }
}