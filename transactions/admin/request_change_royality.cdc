// request_change_royality.cdc

import DAAM from x51e2c02e69b53477

transaction(tokenID: UInt64, creator: Address, newPercentage: UFix64) {
    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeRoyalityRequest(creator: creator, tokenID: tokenID, newPercentage: newPercentage)
        log("Change Royality Requested")
    }
}