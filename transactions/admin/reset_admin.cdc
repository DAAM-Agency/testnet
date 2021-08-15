// reset_admin.cdc

import DAAM_V3.V2 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V3.Admin{DAAM_V3.Founder}>(from: DAAM_V3.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V3.adminPrivatePath)
        admin.unlink(DAAM_V3.requestPrivatePath)
        log("Admin Removed")
    } 
}