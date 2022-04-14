// delete_agent.cdc

import DAAM from 0xfd43f9148d4b725d

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes   <- agent.load<@DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)
        let requestRes <- agent.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
        let minterRes  <- agent.load<@DAAM.Minter>(from: DAAM.minterStoragePath)
        destroy agentRes
        destroy requestRes
        destroy minterRes
        agent.unlink(DAAM.adminPrivatePath)
        agent.unlink(DAAM.requestPrivatePath)
        agent.unlink(DAAM.minterPrivatePath)
        log("Agent & Minter Removed")
    } 
}