// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction(exCreator: Address)
{
    let admin   : &DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath) ?? panic(exCreator.toString().concat(" is not a Creator."))
        self.creator = exCreator
    }

    // Verify is Creator
    pre { DAAM_Mainnet.isCreator(exCreator) != nil : exCreator.toString().concat(" is not a Creator. Can not remove.") }
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }

    post { DAAM_Mainnet.isCreator(self.creator) == nil : self.creator.toString().concat(" has Not been removed.") } // Verify is not a Creator
}
