// change_copyright.cdc

import DAAM from 0xf8d6e0586b0a20c7
    
transaction(mid: UInt64, copyright: Int)
{
    prepare(acct: AuthAccount) {
        var cr = DAAM.CopyrightStatus.FRAUD
        switch(copyright) {
            case 0:
                cr = DAAM.CopyrightStatus.FRAUD
            case 1:
                cr = DAAM.CopyrightStatus.CLAIM
            case 2:
                cr = DAAM.CopyrightStatus.UNVERIFIED
            case 3:
                cr = DAAM.CopyrightStatus.VERIFIED
            default: return
        }
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCopyright(mid: mid, copyright: cr)
        log("Copyright Changed")
    }
}