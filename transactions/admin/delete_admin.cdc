// reset_admin.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        let adminRes <- admin.load<@DAAM_V3.AdminDAAM_V3.Admin>(from: DAAM_V3.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)!
=======
        let adminRes <- admin.load<@DAAM.Admin>(from: DAAM.adminStoragePath)!
        let requestRes <- admin.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
>>>>>>> dev-emulator
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V3.adminPrivatePath)
        admin.unlink(DAAM_V3.requestPrivatePath)
        log("Admin Removed")
    } 
}