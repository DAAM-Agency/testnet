// change_creator_status.cdc

import DAAM from x51e2c02e69b53477

transaction(creator: Address, status: Bool) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.CLAIM

        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCreatorStatus(creator: creator, status: status)
        log("Change Creator Status")   
    }
}// transaction
