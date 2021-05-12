// invite_admin.cdc

import MarketPalace from 0x045a1763c93006ca

transaction(newAdmin: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@MarketPalace.Admin{MarketPalace.Founder}>(from: MarketPalace.adminStoragePath)!
        admin.inviteAdmin(newAdmin: newAdmin)
        acct.save<@MarketPalace.Admin{MarketPalace.Founder}>(<- admin, to: MarketPalace.adminStoragePath)
        log("Admin Invited")
    }
}// transaction
