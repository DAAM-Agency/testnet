// change_creator_status.cdc
// Used for Admin / Agents to change Creator status. True = active, False = frozen

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
<<<<<<< HEAD
<<<<<<< HEAD
    let admin  : &DAAM_V5.Admin
=======
    let admin  : &DAAM.Admin
>>>>>>> dev-emulator
    let creator: Address
    let status : Bool
=======
    let admin   : &{DAAM_V5.Agent}
    let creator : Address
    let status  : Bool
>>>>>>> merge_dev

    prepare(agent: AuthAccount) {
        self.creator = creator  
        self.status  = status
<<<<<<< HEAD
<<<<<<< HEAD
        self.admin = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
=======
        self.admin = acct.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
>>>>>>> dev-emulator
=======
        self.admin = agent.borrow<&{DAAM_V5.Agent}>(from: DAAM_V5.adminStoragePath)!
>>>>>>> merge_dev
    }

    pre { DAAM_V5.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
