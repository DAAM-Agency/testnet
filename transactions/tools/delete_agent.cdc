// delete_agent.cdc

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes  <- agent.load<@DAAM_V8.Admin{DAAM_V8.Agent}>(from: DAAM_V8.adminStoragePath)
        let requestRes  <- agent.load<@DAAM_V8.RequestGenerator>(from: DAAM_V8.requestStoragePath)
        destroy agentRes
        destroy requestRes
        agent.unlink(DAAM_V8.adminPrivatePath)
        agent.unlink(DAAM_V8.requestPrivatePath)
        log("Agent Removed")
    } 
}