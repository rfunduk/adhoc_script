# AdhocScript

So many times, mostly in Rails app, I find myself making a file
like `bin/adhoc/regen_user_avatar_jan_2013.rb` that goes like this:

~~~ ruby
require File.expand_path( '../config/environment.rb', __FILE__ )

User.where( 'avatar_upload IS NOT NULL' ).find_each do |user|
  user.regenerate_avatar!
end
~~~

...or something along those lines. And then I want to know, well, how
long will this take? How far through all these users am I?

What I _don't_ want to do is implement this progress status stuff everytime
myself. So now I can just use `AdhocScript` :)


## Installation

Most likely you update your Gemfile and `bundle install`.

~~~ ruby
gem 'adhoc_script', require: false
~~~


## Usage

The script above becomes:

~~~ ruby
require File.expand_path( '../config/environment.rb', __FILE__ )
require 'adhoc_script'

scope = User.where( 'avatar_upload IS NOT NULL' )
AdhocScript.new( 'Regenerating avatars', scope ).run do |user|
  user.regenerate_avatar!
end
~~~

...almost the same, really. But the output looks like this:

~~~
- Regenerating avatars: 50% (Remaining: 26 minutes)
~~~

...and then a little while later:

~~~
/ Regenerating avatars: 75% (Remaining: 13 minutes)
~~~

You can also use it with just about any object that responds to `#count`:

~~~ ruby
#!/usr/bin/env ruby
# A completely rediculous example!

require 'adhoc_script'

$total = 0
def add( n )
  $total += n
end

AdhocScript.new( 'Count to 10000', (1..100000), :each ).run(&method(:add))

puts "Total: #{$total}"
~~~



## Contributing

Maybe we could use a few other formatters? A progress bar, etc?

1. Clone git://github.com/rfunduk/adhoc_script.git
2. Create local branch.
3. Make changes.
4. `rake test` and return to 3 until passing.
5. Commit, push and open a pull request.
