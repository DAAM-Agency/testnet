// reset_admin.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V2.Admin{DAAM_V2.Founder}>(from: DAAM_V2.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V2.RequestGenerator>(from: DAAM_V2.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V2.adminPrivatePath)
        admin.unlink(DAAM_V2.requestPrivatePath)
        log("Admin Removed")
    } 
}