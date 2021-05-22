// change_commission.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(tokenID: UInt64, artist: Address, newPercentage: UFix64) {
    prepare(acct: AuthAccount) {
        var admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCommission(tokenID: tokenID, artist: artist, newPercentage: newPercentage)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Admin Invited")
    }
}