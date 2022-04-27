// delete_agent.cdc

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes   <- agent.load<@DAAM_V10.Admin{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)
        let requestRes <- agent.load<@DAAM_V10.RequestGenerator>(from: DAAM_V10.requestStoragePath)
        let minterRes  <- agent.load<@DAAM_V10.Minter>(from: DAAM_V10.minterStoragePath)
        destroy agentRes
        destroy requestRes
        destroy minterRes
        agent.unlink(DAAM_V10.adminPrivatePath)
        agent.unlink(DAAM_V10.requestPrivatePath)
        agent.unlink(DAAM_V10.minterPrivatePath)
        log("Agent & Minter Removed")
    } 
}