// invite_creator.cdc

import DAAM_V3.V2 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &{DAAM_V3.Founder}
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&{DAAM_V3.Founder}>(from: DAAM_V3.adminStoragePath)!
        self.creator = creator
    }

    execute {
        self.admin.inviteCreator(self.creator)
        log("Creator Invited")
    }
}
