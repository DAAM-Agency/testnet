// invite_creator.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address)
{
    let admin   : &DAAM.Admin
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.creator = creator
    }

    execute {
        self.admin.inviteCreator(self.creator)
        log("Creator Invited")
    }
}
