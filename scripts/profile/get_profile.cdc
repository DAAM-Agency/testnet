// get_profile.cdc

import DAAM_Mainnet_Profile from 0x0bb80b2a4cb38cdf

pub fun main(address: Address): DAAM_Mainnet_Profile.UserHandler? {
    let ref = getAccount(address)
        .getCapability<&DAAM_Mainnet_Profile.User{DAAM_Mainnet_Profile.Public}>(DAAM_Mainnet_Profile.publicPath)
        .borrow()

    return ref?.getProfile()
}