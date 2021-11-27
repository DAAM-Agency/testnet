// delete_admin.cdc

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)
        let requestRes <- admin.load<@DAAM_V7.RequestGenerator>(from: DAAM_V7.requestStoragePath)
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V7.adminPrivatePath)
        admin.unlink(DAAM_V7.requestPrivatePath)
        log("Admin Removed")
    } 
}