// remove_creator.cdc

import DAAM from 0xf8d6e0586b0a20c7

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
