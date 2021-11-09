// invite_agent.cdc
// Used for Admin to invite another Agent.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM from 0xfd43f9148d4b725d

transaction(newAgent: Address)
{
    let admin    : &DAAM.Admin
    let newAgent : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.newAgent = newAgent
    }

    pre { DAAM.isAdmin(admin.address) } // Verify Access

    execute {
        self.admin.inviteAgent(newAgent: self.newAgent)
        log("Admin Invited")
    }
}
