// remove_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(request: String, creator: Address) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.CLAIM

        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.removeRequest(request: request, creator: creator)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Request Removed")
    }
}// transaction
