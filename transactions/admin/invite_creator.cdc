// invite_creator.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &DAAM_V5.Admin
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        self.creator = creator
    }

    execute {
        self.admin.inviteCreator(self.creator)
        log("Creator Invited")
    }
}
