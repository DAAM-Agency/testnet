// invite_creator.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &{DAAM.Founder}
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        self.creator = creator
    }

    execute {
        self.admin.inviteCreator(self.creator)
        log("Creator Invited")
    }
}
