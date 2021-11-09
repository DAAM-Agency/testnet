// reset_admin.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        let adminRes <- admin.load<@DAAM_V5.AdminDAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V5.RequestGenerator>(from: DAAM_V5.requestStoragePath)!
=======
        let adminRes <- admin.load<@DAAM.Admin>(from: DAAM.adminStoragePath)!
        let requestRes <- admin.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
>>>>>>> dev-emulator
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V5.adminPrivatePath)
        admin.unlink(DAAM_V5.requestPrivatePath)
        log("Admin Removed")
    } 
}