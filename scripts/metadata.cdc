import DAAM             from 0xfd43f9148d4b725d

pub fun main(account: Address): {UInt64 : DAAM.Metadata} {
    let metadataRef = getAccount(account)
        .getCapability<&DAAM.MetadataGenerator>(DAAM.metadataPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadata()
}
