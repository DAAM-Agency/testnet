// delete_admin.cdc
// Debugging Tool
import DAAM_V11 from 0xfd43f9148d4b725d

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V11.Admin>(from: DAAM_V11.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V11.RequestGenerator>(from: DAAM_V11.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V11.adminPrivatePath)
        admin.unlink(DAAM_V11.requestPrivatePath)
        log("Admin Removed")
    } 
}