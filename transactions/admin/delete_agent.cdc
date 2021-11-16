// delete_agent.cdc

import DAAM from 0xfd43f9148d4b725d

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes  <- agent.load<@DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)
        let requestRes  <- agent.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
        destroy agentRes
        destroy requestRes
        agent.unlink(DAAM.agentPrivatePath)
        agent.unlink(DAAM.requestPrivatePath)
        log("Agent Removed")
    } 
}