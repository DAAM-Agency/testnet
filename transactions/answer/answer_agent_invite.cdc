// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V22.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
<<<<<<< HEAD
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V22.adminStoragePath)
            self.signer.save<@DAAM_V22.Admin{DAAM_V22.Agent}>(<- agent!, to: DAAM_V22.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V22.Agent}>(from: DAAM_V22.adminStoragePath)!
=======
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V22.adminStoragePath)
            self.signer.save<@DAAM_V22.Admin{DAAM_V22.Agent}>(<- agent!, to: DAAM_V22.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V22.Agent}>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V22.requestStoragePath)
            let requestGen <- agentRef.newRequestGenerator()!
<<<<<<< HEAD
            self.signer.save<@DAAM_V22.RequestGenerator>(<- requestGen, to: DAAM_V22.requestStoragePath)!
=======
            self.signer.save<@DAAM_V22.RequestGenerator>(<- requestGen, to: DAAM_V22.requestStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_request

            log("You are now a DAAM_V22.Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
<<<<<<< HEAD
            if DAAM_V22.isMinter(self.signer.address) == false { // Received Minter Invitation
                let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V22.minterStoragePath)
                let minter  <- DAAM_V22.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM_V22.Minter>(<- minter!, to: DAAM_V22.minterStoragePath)
                log("You are now a DAAM_V22.Minter: ".concat(self.signer.address.toString()) )
=======
            if DAAM_V22.isMinter(self.signer.address) == false { // Received Minter Invitation
                let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V22.minterStoragePath)
                let minter  <- DAAM_V22.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM_V22.Minter>(<- minter!, to: DAAM_V22.minterStoragePath)
                log("You are now a DAAM_V22.Minter: ".concat(self.signer.address.toString()) )
>>>>>>> 586a0096 (updated FUSD Address)
                destroy old_minter
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
