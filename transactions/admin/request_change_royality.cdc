// request_change_royality.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(tokenID: UInt64, creator: Address, newPercentage: UFix64) {
    prepare(acct: AuthAccount) {
        let admin = acct.borrow<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeRoyalityRequest(creator: creator, tokenID: tokenID, newPercentage: newPercentage)
        log("Change Royality Requested")
    }
}