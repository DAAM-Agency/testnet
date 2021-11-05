// reset_admin.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        let adminRes <- admin.load<@DAAM_V4.AdminDAAM_V4.Admin>(from: DAAM_V4.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V4.RequestGenerator>(from: DAAM_V4.requestStoragePath)!
=======
        let adminRes <- admin.load<@DAAM.Admin>(from: DAAM.adminStoragePath)!
        let requestRes <- admin.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
>>>>>>> dev-emulator
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V4.adminPrivatePath)
        admin.unlink(DAAM_V4.requestPrivatePath)
        log("Admin Removed")
    } 
}