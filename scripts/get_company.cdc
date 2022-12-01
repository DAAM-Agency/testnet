// get_company.cdc

import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

pub fun main(): MetadataViews.Royalty {
	return DAAM.company
}
