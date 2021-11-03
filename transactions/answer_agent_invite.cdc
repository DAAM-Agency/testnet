
// answer_agent_invite.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            self.signer.save<@DAAM.Admin{DAAM.Agent}>(<- agent!, to: DAAM.adminStoragePath)!
            self.signer.link<&DAAM.Admin{DAAM.Agent}>(DAAM.adminPrivatePath, target: DAAM.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)!
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!
            
            log("You are now a DAAM Agent: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
