// init_DAAM_Agency.cdc

transaction(name: String, code: String, agency: Address, cto: Address ) {
    let name  : String
    let agency: {Address: UFix64}
    let deaultAdmins   : [Address]
    let code  : String
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.name   = name
        self.agency = agency
        self.cto    = cto
        self.code   = code
        self.signer = signer
    }

    execute {
        self.signer.contracts.add(name: self.name, code: self.code.decodeHex(), self.agency, self.cto)
    }
}
