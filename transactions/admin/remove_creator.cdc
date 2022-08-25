// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

transaction(exCreator: Address)
{
    let admin   : &DAAM_V22.Admin{DAAM_V22.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
<<<<<<< HEAD
        self.admin   = agent.borrow<&DAAM_V22.Admin{DAAM_V22.Agent}>(from: DAAM_V22.V22.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
=======
        self.admin   = agent.borrow<&DAAM_V22.Admin{DAAM_V22.Agent}>(from: DAAM_V22.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
>>>>>>> 586a0096 (updated FUSD Address)
        self.creator = exCreator
    }

    // Verify is Creator
    pre { DAAM_V22.V22.isCreator(exCreator) != nil : exCreator.toString().concat(" is not a Creator. Can not remove.") }
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

    post { DAAM_V22.V22.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
}
