// invite_admin.cdc

import DAAM_NFT from 0xfd43f9148d4b725d

transaction(newAdmin: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM_NFT.Admin{DAAM_NFT.Founder}>(from: DAAM_NFT.adminStoragePath)!
        admin.inviteAdmin(newAdmin: newAdmin)
        acct.save<@DAAM_NFT.Admin{DAAM_NFT.Founder}>(<- admin, to: DAAM_NFT.adminStoragePath)
        log("Admin Invited")
    }
}// transaction
