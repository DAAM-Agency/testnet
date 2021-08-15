// change_copyright.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: Int)
{
    prepare(acct: AuthAccount) {
        var cr = DAAM_V2.CopyrightStatus.FRAUD
        switch(copyright) {
            case 0:
                cr = DAAM_V2.CopyrightStatus.FRAUD
            case 1:
                cr = DAAM_V2.CopyrightStatus.CLAIM
            case 2:
                cr = DAAM_V2.CopyrightStatus.UNVERIFIED
            case 3:
                cr = DAAM_V2.CopyrightStatus.VERIFIED
            default: return
        }
        let admin = acct.borrow<&DAAM_V2.Admin{DAAM_V2.Founder}>(from: DAAM_V2.adminStoragePath)!
        admin.changeCopyright(mid: mid, copyright: cr)
        log("Copyright Changed")
    }
}