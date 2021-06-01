// remove_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address) {

    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.removeCreator(creator: creator)
        log("Remove Creator")
    }
}// transaction
