// answer_agent_invite.cdc
// Answer the invitation to be an Agent.
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
<<<<<<< HEAD
        let agent  <- DAAM_V10.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V10.adminStoragePath)
            self.signer.save<@DAAM_V10.Admin{DAAM_V10.Agent}>(<- agent!, to: DAAM_V10.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V10.requestStoragePath)
            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V10.RequestGenerator>(<- requestGen, to: DAAM_V10.requestStoragePath)!
            destroy old_request

            log("You are now a DAAM_V10.Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM_V10.isMinter(self.signer.address) == false { // Received Minter Invitation
                let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V10.minterStoragePath)
                let minter  <- DAAM_V10.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM_V10.Minter>(<- minter!, to: DAAM_V10.minterStoragePath)
                log("You are now a DAAM_V10.Minter: ".concat(self.signer.address.toString()) )
=======
        let agent  <- DAAM_V14.answerAgentInvite(newAgent: self.signer, submit: submit)

        if agent != nil && submit {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V14.adminStoragePath)
            self.signer.save<@DAAM_V14.Admin{DAAM_V14.Agent}>(<- agent!, to: DAAM_V14.adminStoragePath)!
            let agentRef = self.signer.borrow<&{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V14.requestStoragePath)
            let requestGen <- agentRef.newRequestGenerator()!
            self.signer.save<@DAAM_V14.RequestGenerator>(<- requestGen, to: DAAM_V14.requestStoragePath)!
            destroy old_request

            log("You are now a DAAM_V14.Agent: ".concat(self.signer.address.toString()) )
            
            // Minter
            if DAAM_V14.isMinter(self.signer.address) == false { // Received Minter Invitation
                let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V14.minterStoragePath)
                let minter  <- DAAM_V14.answerMinterInvite(newMinter: self.signer, submit: submit)
                self.signer.save<@DAAM_V14.Minter>(<- minter!, to: DAAM_V14.minterStoragePath)
                log("You are now a DAAM_V14.Minter: ".concat(self.signer.address.toString()) )
>>>>>>> DAAM_V14
                destroy old_minter
            }
            
        } else {
            destroy agent
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
