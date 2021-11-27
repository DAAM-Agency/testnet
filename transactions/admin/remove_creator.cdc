// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &DAAM_V7.Admin{DAAM_V7.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V7.Admin{DAAM_V7.Agent}>(from: DAAM_V7.adminStoragePath)!
        self.creator = creator
    }

    // Verify is Creator
    pre { DAAM_V7.isCreator(creator) != nil : creator.toString().concat(" is not a Creator. Can not remove.") }
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

    post { DAAM_V7.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
}
