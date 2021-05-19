// invite_admin.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newAdmin: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteAdmin(newAdmin: newAdmin)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Admin Invited")
    }
}// transaction
