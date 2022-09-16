// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(exCreator: Address)
{
    let admin   : &DAAM_V23.Admin{DAAM_V23.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
<<<<<<< HEAD
        self.admin   = agent.borrow<&DAAM_V23.Admin{DAAM_V23.Agent}>(from: DAAM_V23.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
=======
        self.admin   = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM_V23.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
>>>>>>> tomerge
        self.creator = exCreator
    }

    // Verify is Creator
    pre { DAAM_V23.isCreator(exCreator) != nil : exCreator.toString().concat(" is not a Creator. Can not remove.") }
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

    post { DAAM_V23.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
}
