// delete_admin.cdc
// Debugging Tool
import DAAM_V9 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V9.Admin>(from: DAAM_V9.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V9.RequestGenerator>(from: DAAM_V9.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V9.adminPrivatePath)
        admin.unlink(DAAM_V9.requestPrivatePath)
        log("Admin Removed")
    } 
}