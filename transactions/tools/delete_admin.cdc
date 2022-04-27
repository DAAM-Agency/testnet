// delete_admin.cdc
// Debugging Tool
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V10.RequestGenerator>(from: DAAM_V10.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V10.adminPrivatePath)
        admin.unlink(DAAM_V10.requestPrivatePath)
        log("Admin Removed")
    } 
}