// delete_admin.cdc
// Debugging Tool
import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction() {
    prepare(admin: AuthAccount) {
        let adminRes <- admin.load<@DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
        let requestRes <- admin.load<@DAAM_Mainnet.RequestGenerator>(from: DAAM_Mainnet.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        admin.unlink(DAAM_Mainnet.adminPrivatePath)
        admin.unlink(DAAM_Mainnet.requestPrivatePath)
        log("Admin Removed")
    } 
}