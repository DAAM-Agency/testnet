// delete_admin.cdc
// Debugging Tool
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V15.RequestGenerator>(from: DAAM_V15.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V15.adminPrivatePath)
        admin.unlink(DAAM_V15.requestPrivatePath)
        log("Admin Removed")
    } 
}