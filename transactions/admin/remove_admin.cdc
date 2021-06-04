// remove_creator.cdc

import DAAM from x51e2c02e69b53477

transaction(xadmin: Address) {

    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.removeAdmin(admin: xadmin)
        log("Remove Admin Requested")
    }
}// transaction
