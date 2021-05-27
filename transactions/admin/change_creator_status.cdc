// change_creator_status.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address, status: UFix64) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.CLAIM

        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCreatorStatus(creator: creator, status: status)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Request Removed")
    }
}// transaction
