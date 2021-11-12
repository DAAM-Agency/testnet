// change_copyright.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: Int)
{
    prepare(acct: AuthAccount) {
        var cr: DAAM_V5.CopyrightStatus = DAAM_V5.CopyrightStatus.FRAUD
        switch(copyright) {
            case 0:
                cr = DAAM_V5.CopyrightStatus.FRAUD
            case 1:
                cr = DAAM_V5.CopyrightStatus.CLAIM
            case 2:
                cr = DAAM_V5.CopyrightStatus.UNVERIFIED
            case 3:
                cr = DAAM_V5.CopyrightStatus.VERIFIED
            default: return
        }

        pre { copyright < 5 } // 

        let admin = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        admin.changeCopyright(mid: mid, copyright: cr)
        log("Copyright Changed")
    }
}