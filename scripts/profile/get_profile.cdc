// get_profile.cdc

import DAAM_Mainnet_Profile from 0x192440c99cb17282

pub fun main(address: Address): DAAM_Mainnet_Profile.UserHandler? {
    let ref = getAccount(address)
        .getCapability<&DAAMDAAM_Mainnet_Mainnet_Profile.User{DAAM_Mainnet_Profile.Public}>(DAAM_Mainnet_Profile.publicPath)
        .borrow()

    return ref?.getProfile()
}