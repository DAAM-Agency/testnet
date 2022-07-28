// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_V21 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_V21.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V21.adminStoragePath)
            self.signer.save<@DAAM_V21.Admin{DAAM_V21.Agent}>(<- agent!, to: DAAM_V21.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V21.Agent}>(from: DAAM_V21.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V21.requestStoragePath)
            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V21.RequestGenerator>(<- requestGen, to: DAAM_V21.requestStoragePath)!
            destroy old_request

            log("You are now a DAAM_V21.Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM_V21.isMinter(self.signer.address) == false { // Received Minter Invitation
                let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V21.minterStoragePath)
                let minter  <- DAAM_V21.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM_V21.Minter>(<- minter!, to: DAAM_V21.minterStoragePath)
                log("You are now a DAAM_V21.Minter: ".concat(self.signer.address.toString()) )
                destroy old_minter
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
