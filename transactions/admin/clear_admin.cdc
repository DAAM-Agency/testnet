// clear_admin.cdc

import DAAM       from 0xa4ad5ea5c0bd2fba
import DAAM_V1 from 0xa4ad5ea5c0bd2fba
import DAAM_V2 from 0xa4ad5ea5c0bd2fba
import DAAM_V3 from 0xa4ad5ea5c0bd2fba
import DAAM_V4 from 0xa4ad5ea5c0bd2fba
import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)
        let requestRes <- admin.load<@DAAM_V7.RequestGenerator>(from: DAAM_V7.requestStoragePath)
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_V7.adminPrivatePath)
        admin.unlink(DAAM_V7.requestPrivatePath)
        log("Admin Removed")

        let adminRes1 <- admin.load<@DAAM_V7.V1.Admin>(from: DAAM_V7.V1.adminStoragePath)
        let requestRes1 <- admin.load<@DAAM_V7.V1.RequestGenerator>(from: DAAM_V7.V1.requestStoragePath)
        destroy adminRes1
        destroy requestRes1
        admin.unlink(DAAM_V7.V1.adminPrivatePath)
        admin.unlink(DAAM_V7.V1.requestPrivatePath)
        log("Admin Removed 1")

        let adminRes2 <- admin.load<@DAAM_V7.V2.Admin>(from: DAAM_V7.V2.adminStoragePath)
        let requestRes2 <- admin.load<@DAAM_V7.V2.RequestGenerator>(from: DAAM_V7.V2.requestStoragePath)
        destroy adminRes2
        destroy requestRes2
        admin.unlink(DAAM_V7.V2.adminPrivatePath)
        admin.unlink(DAAM_V7.V2.requestPrivatePath)
        log("Admin Removed 2")

        let adminRes3 <- admin.load<@DAAM_V7.V3.Admin>(from: DAAM_V7.V3.adminStoragePath)
        let requestRes3 <- admin.load<@DAAM_V7.V3.RequestGenerator>(from: DAAM_V7.V3.requestStoragePath)
        destroy adminRes3
        destroy requestRes3
        admin.unlink(DAAM_V7.V3.adminPrivatePath)
        admin.unlink(DAAM_V7.V3.requestPrivatePath)
        log("Admin Removed 3")

        let adminRes4 <- admin.load<@DAAM_V7.V4.Admin>(from: DAAM_V7.V4.adminStoragePath)
        let requestRes4 <- admin.load<@DAAM_V7.V4.RequestGenerator>(from: DAAM_V7.V4.requestStoragePath)
        destroy adminRes4
        destroy requestRes4
        admin.unlink(DAAM_V7.V4.adminPrivatePath)
        admin.unlink(DAAM_V7.V4.requestPrivatePath)
        log("Admin Removed 4")

        let adminRes5 <- admin.load<@DAAM_V7.V5.Admin>(from: DAAM_V7.V5.adminStoragePath)
        let requestRes5 <- admin.load<@DAAM_V7.V5.RequestGenerator>(from: DAAM_V7.V5.requestStoragePath)
        destroy adminRes4
        destroy requestRes4
        admin.unlink(DAAM_V7.V5.adminPrivatePath)
        admin.unlink(DAAM_V7.V5.requestPrivatePath)
        log("Admin Removed 5")
    } 
}