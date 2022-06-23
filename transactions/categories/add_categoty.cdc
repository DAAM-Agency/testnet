// add_category.cdc

// Adding a new category to the contract Categories

import Categories from 0xa4ad5ea5c0bd2fba

transaction(category: String) {
    let category: String
    prepare(signer: AuthAccount) { self.category = category }

    pre { !Categories.getCategories().contains(category) }

    execute {
        Categories.addCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" added."))
    }
}