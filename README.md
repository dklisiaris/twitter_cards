# TwitterCards

A very simple Ruby library for parsing Twitter Cards information from websites.
See https://dev.twitter.com/cards/types for more information.

[![Dependency Status](https://gemnasium.com/dklisiaris/twitter_cards.svg)](https://gemnasium.com/dklisiaris/twitter_cards)
[![Build Status](https://travis-ci.org/dklisiaris/twitter_cards.svg?branch=master)](https://travis-ci.org/dklisiaris/twitter_cards)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twitter_cards', '~> 0.1'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install twitter_cards


## Usage

```ruby
require 'twitter_cards'
    
article = TwitterCards.fetch('http://www.bbc.com/news/technology-32422193')
    
article.title # => "Google launches Project Fi mobile phone network - BBC News"

article.description # => "Google announces Project Fi, a mobile network that will piggyback existing services in the US but offer different terms."

article.image # => "http://ichef.bbci.co.uk/news/560/media/images/82498000/jpg/_82498457_82498453.jpg"

# Check if cards belongs to a specific type
article.summary_large_image? # => true
article.gallery? # => false

# Get card's type
article.type # => "summary_large_image"

# Check if attribute is present by using attribute?
article.domain? # => true
article.domain # => "www.bbc.com" 

# Check if all required (as specified by twitter) attributes are present
article.valid?
```   

If you try to fetch Twitter Cards information for a URL that doesn't 
have any, the _fetch_ method will return _false_.
The TwitterCards::Object that is returned is just a Hash with accessors
built into it, so you can examine what properties you've retrieved like so:

```ruby
article.keys # => ["card", "site", "title", "description", "creator", "image_src", "domain"] 
```

If you have some html already downloaded you can use `parse` method.
```ruby
article = TwitterCards.parse(html)
```

If you already have parsed html with nokogiri you can use `extract` method.
```ruby
article = TwitterCards.extract(doc)
```

By default, every attribute is extracted from page. If you want to extract cards only when they have all required attributes you can pass _:strict_ option set to true.
```ruby
article = TwitterCards.fetch('http://www.bbc.com/news/technology-32422193', strict: true)
```

__Note:__ Both `image` and `image_src` attributes can be accessed with `.image` method.

__Note 2:__ Attributes like `app:id:googleplay` are converted to `app_id_googleplay`

__Note 3:__ This library supports only one card per page.

## Development

After forking/checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/dklisiaris/twitter_cards/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
