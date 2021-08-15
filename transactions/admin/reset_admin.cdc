// reset_admin.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V1.Admin{DAAM_V1.Founder}>(from: DAAM_V1.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V1.RequestGenerator>(from: DAAM_V1.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V1.adminPrivatePath)
        admin.unlink(DAAM_V1.requestPrivatePath)
        log("Admin Removed")
    } 
}