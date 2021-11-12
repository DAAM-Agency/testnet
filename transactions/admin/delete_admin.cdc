// delete_admin.cdc
// Debugging Tool

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V6.Admin>(from: DAAM_V6.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V6.RequestGenerator>(from: DAAM_V6.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V6.adminPrivatePath)
        admin.unlink(DAAM_V6.requestPrivatePath)
        log("Admin Removed")
    } 
}