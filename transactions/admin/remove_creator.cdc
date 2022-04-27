// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &DAAM_V9.Admin{DAAM_V9.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V9.Admin{DAAM_V9.Agent}>(from: DAAM_V9.adminStoragePath)!
        self.creator = creator
    }

    // Verify is Creator
    pre { DAAM_V9.isCreator(creator) != nil : creator.toString().concat(" is not a Creator. Can not remove.") }
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

    post { DAAM_V9.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
}
