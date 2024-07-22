require 'sso/elements/fmk'

# Creates a new collection
collection = SSO::Elements::Collection.new

# Loads a custom config
collection.load_config!(150)

# Load all elements from file
collection.load_elements!('./lib/sso/elements/samples/elements.data')

# Gets Npc Essence table
npc_essence = collection.table('NpcEssence')

# Gets a random NPC
some_random_npc = npc_essence.find_element_by_id 4850

# Clones the npc into a new one
npc = some_random_npc.clone

# Set new npc custom properties
npc.id = 120031
npc.name = 'Donovan'
npc.item_exchange_service = 0
npc.file_model = 2023
npc.file_icon = 4713
npc.name_prof_prefix = 'Just someone'

# Adds the new npc to the collection
npc_essence.add_element(npc)

# Persists elements into a new file
collection.save!('./lib/sso/elements/samples/new_elements.data')