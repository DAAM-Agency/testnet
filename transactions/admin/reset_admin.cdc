// reset_admin.cdc

import DAAM from 0xfd43f9148d4b725d

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        let requestRes <- admin.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM.adminPrivatePath)
        admin.unlink(DAAM.requestPublicPath)
        log("Admin Removed")
    } 
}