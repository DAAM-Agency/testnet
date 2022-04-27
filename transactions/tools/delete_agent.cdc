// delete_agent.cdc

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes   <- agent.load<@DAAM_V9.Admin{DAAM_V9.Agent}>(from: DAAM_V9.adminStoragePath)
        let requestRes <- agent.load<@DAAM_V9.RequestGenerator>(from: DAAM_V9.requestStoragePath)
        let minterRes  <- agent.load<@DAAM_V9.Minter>(from: DAAM_V9.minterStoragePath)
        destroy agentRes
        destroy requestRes
        destroy minterRes
        agent.unlink(DAAM_V9.adminPrivatePath)
        agent.unlink(DAAM_V9.requestPrivatePath)
        agent.unlink(DAAM_V9.minterPrivatePath)
        log("Agent & Minter Removed")
    } 
}