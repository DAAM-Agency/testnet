// change_copyright.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: Int)
{
    prepare(acct: AuthAccount) {
        var cr = DAAM_V3.CopyrightStatus.FRAUD
        switch(copyright) {
            case 0:
                cr = DAAM_V3.CopyrightStatus.FRAUD
            case 1:
                cr = DAAM_V3.CopyrightStatus.CLAIM
            case 2:
                cr = DAAM_V3.CopyrightStatus.UNVERIFIED
            case 3:
                cr = DAAM_V3.CopyrightStatus.VERIFIED
            default: return
        }
        let admin = acct.borrow<&DAAM_V3.Admin{DAAM_V3.Founder}>(from: DAAM_V3.adminStoragePath)!
        admin.changeCopyright(mid: mid, copyright: cr)
        log("Copyright Changed")
    }
}