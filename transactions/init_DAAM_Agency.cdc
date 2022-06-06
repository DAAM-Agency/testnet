// init_DAAM_V11_Agency.cdc

transaction(name: String, code: String, founders: {Address: UFix64}, defaultAdmins: [Address] ) {
    let name          : String
    let founders      : {Address: UFix64}
    let defaultAdmins : [Address]
    let code          : String
    let signer        : AuthAccount

    prepare(signer: AuthAccount) {
        self.name          = name
        self.founders      = founders
        self.defaultAdmins = defaultAdmins
        self.code          = code
        self.signer        = signer
    }

    execute {
        log(self.founders)
        log(self.defaultAdmins)
        self.signer.contracts.add(name: self.name, code: self.code.decodeHex(), self.founders, self.defaultAdmins)
    }
}
