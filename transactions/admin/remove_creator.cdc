// remove_creator.cdc
// Used for Admin / Agents to remove Creator

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(exCreator: Address)
{
<<<<<<< HEAD
    let admin   : &DAAM_V10.Admin{DAAM_V10.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V10.Admin{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)!
        self.creator = creator
    }

    // Verify is Creator
    pre { DAAM_V10.isCreator(creator) != nil : creator.toString().concat(" is not a Creator. Can not remove.") }
=======
    let admin   : &DAAM_V14.Admin{DAAM_V14.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V14.Admin{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
        self.creator = exCreator
    }

    // Verify is Creator
    pre { DAAM_V14.isCreator(exCreator) != nil : exCreator.toString().concat(" is not a Creator. Can not remove.") }
>>>>>>> DAAM_V14
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

<<<<<<< HEAD
    post { DAAM_V10.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
=======
    post { DAAM_V14.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
>>>>>>> DAAM_V14
}
