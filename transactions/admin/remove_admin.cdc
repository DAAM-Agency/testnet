// remove_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(xadmin: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.removeAdmin(admin: xadmin)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Remove Admin Requested")
    }
}// transaction
