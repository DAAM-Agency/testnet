// answer_agent_invite.cdc
// Answer the invitation to be an Agent.

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V5.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            self.signer.save<@DAAM_V5.Admin{DAAM_V5.Agent}>(<- agent!, to: DAAM_V5.adminStoragePath)!
            self.signer.link<&{DAAM_V5.Agent}>(DAAM_V5.adminPrivatePath, target: DAAM_V5.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V5.Agent}>(from: DAAM_V5.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V5.RequestGenerator>(<- requestGen, to: DAAM_V5.requestStoragePath)!
            self.signer.link<&DAAM_V5.RequestGenerator>(DAAM_V5.requestPrivatePath, target: DAAM_V5.requestStoragePath)!
            
            log("You are now a DAAM_V5 Agent: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
