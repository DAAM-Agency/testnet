// reset_admin.cdc

import DAAM from 0xf8d6e0586b0a20c7

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        let requestRes <- admin.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM.adminPrivatePath)
        admin.unlink(DAAM.requestPrivatePath)
        log("Admin Removed")
    } 
}