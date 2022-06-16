// change_creator_status.cdc
// Used for Admin / Agents to change Creator status. True = active, False = frozen

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
    let admin   : &{DAAM_V10.Agent}
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
    let admin   : &{DAAM_V14.Agent}
>>>>>>> DAAM_V14
    let creator : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.creator = creator  
        self.status  = status
<<<<<<< HEAD
        self.admin = agent.borrow<&{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)!
    }

    pre { DAAM_V10.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }
=======
        self.admin = agent.borrow<&{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)!
    }

    pre { DAAM_V14.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }
>>>>>>> DAAM_V14

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
