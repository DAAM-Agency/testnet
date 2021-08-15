// remove_creator.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &{DAAM_V1.Founder}
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&DAAM_V1.Admin{DAAM_V1.Founder}>(from: DAAM_V1.adminStoragePath)!
        self.creator = creator
    }

    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }
}
