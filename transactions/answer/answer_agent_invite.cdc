// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

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
            self.signer.link<&{DAAM.Agent}>(DAAM.adminPrivatePath, target: DAAM.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!

            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)!
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!

            log("You are now a DAAM Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM.isMinter(self.signer.address) == false { // Received Minter Invitation
                let minter  <- DAAM.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM.Minter>(<- minter!, to: DAAM.minterStoragePath)!
                self.signer.link<&DAAM.Minter>(DAAM.minterPrivatePath, target: DAAM.minterStoragePath)!
                log("You are now a DAAM Minter: ".concat(self.signer.address.toString()) )
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}