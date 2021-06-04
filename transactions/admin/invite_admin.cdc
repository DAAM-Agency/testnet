// invite_admin.cdc

import DAAM from x51e2c02e69b53477

transaction(newAdmin: Address) {

    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteAdmin(newAdmin: newAdmin)
        log("Admin Invited")
    }
}// transaction
