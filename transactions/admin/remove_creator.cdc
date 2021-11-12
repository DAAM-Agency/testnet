// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
<<<<<<< HEAD
    let admin   : &DAAM_V5.Admin
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
=======
    let admin   : &{DAAM_V5.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&{DAAM_V5.Agent}>(from: DAAM_V5.adminStoragePath)!
>>>>>>> merge_dev
        self.creator = creator
    }

    // Verify is Creator
    pre { DAAM_V5.isCreator(creator) != nil : creator.toString().concat(" is not a Creator. Can not remove.") }
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

    post { DAAM_V5.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
}
