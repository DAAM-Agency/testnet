// answer_agent_invite.cdc
// Answer the invitation to be an Agent.

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let agent <- DAAM_V8.answerAgentInvite(newAgent: self.signer, submit: self.submit)
        if agent != nil {
            self.signer.save<@DAAM_V8.Admin{DAAM_V8.Agent}>(<- agent!, to: DAAM_V8.adminStoragePath)
            let agentRef = self.signer.borrow<&{DAAM_V8.Agent}>(from: DAAM_V8.adminStoragePath)!

            let requestGen <-! agentRef.newRequestGenerator()
            self.signer.save<@DAAM_V8.RequestGenerator>(<- requestGen, to: DAAM_V8.requestStoragePath)
            
            log("You are now a DAAM_V8.Agent: ".concat(self.signer.address.toString()) )
        } else {
            destroy agent
            log("Thank You for your consoderation.")
        }
    }
}
