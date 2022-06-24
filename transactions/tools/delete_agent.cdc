// delete_agent.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes   <- agent.load<@DAAM_V15.Admin{DAAM_V15.Agent}>(from: DAAM_V15.adminStoragePath)
        let requestRes <- agent.load<@DAAM_V15.RequestGenerator>(from: DAAM_V15.requestStoragePath)
        let minterRes  <- agent.load<@DAAM_V15.Minter>(from: DAAM_V15.minterStoragePath)
        destroy agentRes
        destroy requestRes
        destroy minterRes
        agent.unlink(DAAM_V15.adminPrivatePath)
        agent.unlink(DAAM_V15.requestPrivatePath)
        agent.unlink(DAAM_V15.minterPrivatePath)
        log("Agent & Minter Removed")
    } 
}