
// answer_agent_invite.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V4.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            self.signer.save<@DAAM_V4.Admin{DAAM_V4.Agent}>(<- agent!, to: DAAM_V4.adminStoragePath)!
            self.signer.link<&{DAAM_V4.Agent}>(DAAM_V4.adminPrivatePath, target: DAAM_V4.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V4.Agent}>(from: DAAM_V4.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V4.RequestGenerator>(<- requestGen, to: DAAM_V4.requestStoragePath)!
            self.signer.link<&DAAM_V4.RequestGenerator>(DAAM_V4.requestPrivatePath, target: DAAM_V4.requestStoragePath)!
            
            log("You are now a DAAM Agent: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
