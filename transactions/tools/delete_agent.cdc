// delete_agent.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(agent: AuthAccount) {
        let agentRes   <- agent.load<@DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)
        let requestRes <- agent.load<@DAAM_Mainnet.RequestGenerator>(from: DAAM_Mainnet.requestStoragePath)
        let minterRes  <- agent.load<@DAAM_Mainnet.Minter>(from: DAAM_Mainnet.minterStoragePath)
        destroy agentRes
        destroy requestRes
        destroy minterRes
        agent.unlink(DAAM_Mainnet.adminPrivatePath)
        agent.unlink(DAAM_Mainnet.requestPrivatePath)
        agent.unlink(DAAM_Mainnet.minterPrivatePath)
        log("Agent & Minter Removed")
    } 
}