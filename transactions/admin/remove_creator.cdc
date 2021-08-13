// remove_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address)
{
    let admin   : &{DAAM.Founder}
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        self.creator = creator
    }

    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }
}
