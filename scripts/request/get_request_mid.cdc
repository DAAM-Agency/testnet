import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(): [UInt64] {
    return DAAM_Mainnet.getRequestMIDs()
}