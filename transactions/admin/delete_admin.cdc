// delete_admin.cdc
// Debugging Tool

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V5.RequestGenerator>(from: DAAM_V5.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V5.adminPrivatePath)
        admin.unlink(DAAM_V5.requestPrivatePath)
        log("Admin Removed")
    } 
}