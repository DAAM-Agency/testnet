// change_creator_status.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address, status: Bool) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.CLAIM

        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCreatorStatus(creator: creator, status: status)
        log("Change Creator Status")   
    }
}// transaction
