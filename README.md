# OodSupport

Open OnDemand gem that provides a set of support objects to interface with the
local OS installed on the HPC Center's web node.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ood_support'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ood_support

## Usage

### User

Provides a simplified system-level user object that can be used to determine
user's id, groups, shell, home directory...

```ruby
require 'ood_support'

# Generate OodSupport::User object from user name
u = OodSupport::User.new 'user1'

# User name
u.name
#=> "user1"

# User id
u.id
#=> 1000

# User shell
u.shell
#=> "/bin/bash"

# Array of groups user is in
u.groups
#=> [<OodSupport::Group ...>, <OodSupport::Group ...>, ...]

# Names of groups user is in
u.groups.map(&:name)
#=> ["primary_group", "group1", "group2"]

# Name of user's primary group
u.group.name
#=> "primary_group"

# Whether user is in group called "group15"
u.in_group? "group15"
#=> false

# Use it in a string
puts "Hello #{u}!"
#=> "Hello user1!"
```

You can generate the `OodSupport::User` object from a user name, user id,
another `OodSupport::User`, or from the running process:

```ruby
require 'ood_support'

# Generate OodSupport::User object from user name
u1 = OodSupport::User.new 'user1'

# Generate OodSupport::User object from user id
u2 = OodSupport::User.new 1000

# Generate OodSupport::User object from another object
u3 = OodSupport::User.new u1

# Generate OodSupport::User from running process
me = OodSupport::User.new
```

### Group

Provides a simplified system-level group object that can be used to determine
group id and group name.

```ruby
require 'ood_support'

# Generate OodSupport::Group object from group name
g = OodSupport::Group.new 'group1'

# Get group id
g.id
#=> 100

# Get group name
g.name
#=> 'group1'

# Generate OodSupport::User object from user name
u = OodSupport::User.new 'user1'

# Sort the list of groups user is in
u.groups.sort.map(&:name)
#=> ["a_group", "b_group", "c_group"]
```

You can generate the `OodSupport::Group` object from a group name, group id,
another `OodSupport::Group` object, or from the running process:

```ruby
require 'ood_support'

# Generate OodSupport::Group object from user name
g1 = OodSupport::Group.new 'group1'

# Generate OodSupport::Group object from user id
g2 = OodSupport::Group.new 100

# Generate OodSupport::Group object from another object
g3 = OodSupport::Group.new g1

# Generate OodSupport::Group from running process
me = OodSupport::Group.new
```

### Process

Provides a simplified interface to the running process that can be used to
determine owner of the process as well as whether the owner's groups have
changed since the process started.

```ruby
require 'ood_support'

# Get owner of process
OodSupport::Process.user
#=> <OodSupport::User ...>

# Get primary group of process
OodSupport::Process.group
#=> <OodSupport::Group ...>

# Get list of groups process is currently in
OodSupport::Process.groups
#=> [<OodSupport::Group ...>, <OodSupport::Group ...>, ...]

# Whether owner's groups changed since process started
OodSupport::Process.groups_changed?
#=> false
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ood_support/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
