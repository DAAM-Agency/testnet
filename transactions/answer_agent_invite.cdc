// answer_agent_invite.cdc
// Answer the invitation to be an Agent.

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V6.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            self.signer.save<@DAAM_V6.Admin{DAAM_V6.Agent}>(<- agent!, to: DAAM_V6.adminStoragePath)!
            self.signer.link<&{DAAM_V6.Agent}>(DAAM_V6.adminPrivatePath, target: DAAM_V6.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V6.Agent}>(from: DAAM_V6.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V6.RequestGenerator>(<- requestGen, to: DAAM_V6.requestStoragePath)!
            self.signer.link<&DAAM_V6.RequestGenerator>(DAAM_V6.requestPrivatePath, target: DAAM_V6.requestStoragePath)!
            
            log("You are now a DAAM_V6 Agent: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
