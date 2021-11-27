// delete_agent.cdc

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes  <- agent.load<@DAAM_V6.Admin{DAAM_V6.Agent}>(from: DAAM_V6.adminStoragePath)
        let requestRes  <- agent.load<@DAAM_V6.RequestGenerator>(from: DAAM_V6.requestStoragePath)
        destroy agentRes
        destroy requestRes
        agent.unlink(DAAM_V6.adminPrivatePath)
        agent.unlink(DAAM_V6.requestPrivatePath)
        log("Agent Removed")
    } 
}