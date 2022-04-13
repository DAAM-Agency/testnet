// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V7.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            self.signer.save<@DAAM_V7.Admin{DAAM_V7.Agent}>(<- agent!, to: DAAM_V7.adminStoragePath)!
            self.signer.link<&{DAAM_V7.Agent}>(DAAM_V7.adminPrivatePath, target: DAAM_V7.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V7.Agent}>(from: DAAM_V7.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V7.RequestGenerator>(<- requestGen, to: DAAM_V7.requestStoragePath)!
            self.signer.link<&DAAM_V7.RequestGenerator>(DAAM_V7.requestPrivatePath, target: DAAM_V7.requestStoragePath)!

            log("You are now a DAAM Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM_V7.isMinter(self.signer.address) == false { // Received Minter Invitation
                let minter  <- DAAM_V7.answerMinterInvite(minter: self.signer, submit: submit)
                self.signer.save<@DAAM_V7.Minter>(<- minter!, to: DAAM_V7.minterStoragePath)!
                self.signer.link<&DAAM_V7.Minter>(DAAM_V7.minterPrivatePath, target: DAAM_V7.minterStoragePath)!
                log("You are now a DAAM Minter: ".concat(self.signer.address.toString()) )
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
