// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let agent  <- DAAM_Mainnet.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.adminStoragePath)
            self.signer.save<@DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}>(<- agent!, to: DAAM_Mainnet.adminStoragePath)!
            let agentRef = self.signer.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.requestStoragePath)
            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_Mainnet.RequestGenerator>(<- requestGen, to: DAAM_Mainnet.requestStoragePath)!
            destroy old_request

            log("You are now a DAAM_Mainnet.Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM_Mainnet.isMinter(self.signer.address) == false { // Received Minter Invitation
                let old_minter <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.minterStoragePath)
                let minter  <- DAAM_Mainnet.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM_Mainnet.Minter>(<- minter!, to: DAAM_Mainnet.minterStoragePath)
                log("You are now a DAAM_Mainnet.Minter: ".concat(self.signer.address.toString()) )
                destroy old_minter
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
 