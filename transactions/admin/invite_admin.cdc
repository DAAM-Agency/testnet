// invite_admin.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newAdmin: Address) {

    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteAdmin(newAdmin: newAdmin)
        log("Admin Invited")
    }
}// transaction
