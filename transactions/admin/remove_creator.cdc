// remove_creator.cdc
// Used for Admin / Agents to remove Creator

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(exCreator: Address)
{
    let admin   : &DAAM_V14.Admin{DAAM_V14.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V14.Admin{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(exCreator: Address)
{
    let admin   : &DAAM_V15.Admin{DAAM_V15.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V15.Admin{DAAM_V15.Agent}>(from: DAAM_V15.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
>>>>>>> DAAM_V15
        self.creator = exCreator
    }

    // Verify is Creator
<<<<<<< HEAD
    pre { DAAM_V14.isCreator(exCreator) != nil : exCreator.toString().concat(" is not a Creator. Can not remove.") }
=======
    pre { DAAM_V15.isCreator(exCreator) != nil : exCreator.toString().concat(" is not a Creator. Can not remove.") }
>>>>>>> DAAM_V15
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

<<<<<<< HEAD
    post { DAAM_V14.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
=======
    post { DAAM_V15.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
>>>>>>> DAAM_V15
}
