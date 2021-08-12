// change_copyright.cdc

<<<<<<< HEAD
import DAAM from x51e2c02e69b53477

transaction(metadataID: UInt64, /*copyright: DAAM.CopyrightStatus*/) {

=======
import DAAM from 0xa4ad5ea5c0bd2fba
    
transaction(mid: UInt64, copyright: Int) {
    
>>>>>>> dev
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