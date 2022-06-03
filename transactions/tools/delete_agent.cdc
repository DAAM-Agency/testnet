// delete_agent.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes   <- agent.load<@DAAM_V11.Admin{DAAM_V11.Agent}>(from: DAAM_V11.adminStoragePath)
        let requestRes <- agent.load<@DAAM_V11.RequestGenerator>(from: DAAM_V11.requestStoragePath)
        let minterRes  <- agent.load<@DAAM_V11.Minter>(from: DAAM_V11.minterStoragePath)
        destroy agentRes
        destroy requestRes
        destroy minterRes
        agent.unlink(DAAM_V11.adminPrivatePath)
        agent.unlink(DAAM_V11.requestPrivatePath)
        agent.unlink(DAAM_V11.minterPrivatePath)
        log("Agent & Minter Removed")
    } 
}