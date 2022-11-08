// check_profile.cdc

import DAAM_Mainnet_Profile from 0x0bb80b2a4cb38cdf

pub fun main(address: Address): Bool {
    return DAAM_Mainnet_Profile.check(address)
}