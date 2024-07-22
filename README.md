# SSO::Elements::Fmk

Simple SSO elements editor for Ruby

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sso-elements-fmk

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sso-elements-fmk

## Usage

Here you can see a basic sample of how to create an NPC

```ruby
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
```

More samples can be found [here](https://github.com/kuroro7/sso-elements-fmk/tree/master/examples)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kuroro7/sso-elements-fmk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/sso-elements-fmk/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [LGPL License](https://www.gnu.org/licenses/lgpl-3.0.txt).

## Code of Conduct

Everyone interacting in the SSO::Elements::Fmk project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sso-elements-fmk/blob/master/CODE_OF_CONDUCT.md).
