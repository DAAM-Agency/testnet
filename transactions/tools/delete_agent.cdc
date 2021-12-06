// delete_agent.cdc

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes  <- agent.load<@DAAM_V7.Admin{DAAM_V7.Agent}>(from: DAAM_V7.adminStoragePath)
        let requestRes  <- agent.load<@DAAM_V7.RequestGenerator>(from: DAAM_V7.requestStoragePath)
        destroy agentRes
        destroy requestRes
        agent.unlink(DAAM_V7.adminPrivatePath)
        agent.unlink(DAAM_V7.requestPrivatePath)
        log("Agent Removed")
    } 
}