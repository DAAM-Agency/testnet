// delete_admin.cdc
// Debugging Tool
import DAAM_V8.V8.V8_V8.. from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V8.V8..Admin>(from: DAAM_V8.V8..adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V8.V8..RequestGenerator>(from: DAAM_V8.V8..requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V8.V8..adminPrivatePath)
        admin.unlink(DAAM_V8.V8..requestPrivatePath)
        log("Admin Removed")
    } 
}