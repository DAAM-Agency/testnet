// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V8.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            self.signer.save<@DAAM_V8.Admin{DAAM_V8.Agent}>(<- agent!, to: DAAM_V8.adminStoragePath)!
            self.signer.link<&{DAAM_V8.Agent}>(DAAM_V8.adminPrivatePath, target: DAAM_V8.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V8.Agent}>(from: DAAM_V8.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V8.RequestGenerator>(<- requestGen, to: DAAM_V8.requestStoragePath)!
            self.signer.link<&DAAM_V8.RequestGenerator>(DAAM_V8.requestPrivatePath, target: DAAM_V8.requestStoragePath)!

            log("You are now a DAAM Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM_V8.isMinter(self.signer.address) == false { // Received Minter Invitation
                let minter  <- DAAM_V8.answerMinterInvite(minter: self.signer, submit: submit)
                self.signer.save<@DAAM_V8.Minter>(<- minter!, to: DAAM_V8.minterStoragePath)!
                self.signer.link<&DAAM_V8.Minter>(DAAM_V8.minterPrivatePath, target: DAAM_V8.minterStoragePath)!
                log("You are now a DAAM Minter: ".concat(self.signer.address.toString()) )
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}

    execute {

        if minter != nil && submit {
            
        } else {
            destroy minter
        }

        if !submit { log("Thank You for your consideration.") }
    }
}

