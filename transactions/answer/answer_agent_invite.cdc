// answer_agent_invite.cdc
// Answer the invitation to be an Agent.

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let agent <- DAAM.answerAgentInvite(newAgent: self.signer, submit: self.submit)
        if agent != nil {
            self.signer.save<@DAAM.Admin{DAAM.Agent}>(<- agent!, to: DAAM.adminStoragePath)
            let agentRef = self.signer.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!

            let requestGen <-! agentRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)
            
            log("You are now a DAAM Agent: ".concat(self.signer.address.toString()) )
        } else {
            destroy agent
            log("Thank You for your consoderation.")
        }
    }
}
