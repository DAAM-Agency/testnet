// invite_admin.cdc

import DAAM from 0x045a1763c93006ca

transaction(newAdmin: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteAdmin(newAdmin: newAdmin)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Admin Invited")
    }
}// transaction
