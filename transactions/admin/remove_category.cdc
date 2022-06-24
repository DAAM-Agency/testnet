// remove_category.cdc
// Remove a new category to contract Category

import Categories from 0xfd43f9148d4b725d
import DAAM       from 0xfd43f9148d4b725d

transaction(category: String) {
    let category: String
    let admin   : &DAAM.Admin

    prepare(admin: AuthAccount) {
        self.category = category
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
    }

    pre { Categories.getCategories().contains(category) }

    execute {
        self.admin.removeCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" removed."))
    }
}
