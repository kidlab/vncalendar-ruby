# Vncalendar

[![Build Status](https://travis-ci.org/kidlab/vncalendar-ruby.svg?branch=master)](https://travis-ci.org/kidlab/vncalendar-ruby) [![Gem Version](https://badge.fury.io/rb/vncalendar.svg)](https://badge.fury.io/rb/vncalendar)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vncalendar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vncalendar

## Usage

- Convert solar date or Gregorian date - our regular date, to lunar date:

```ruby
UTC_OFFSET = 7 # Asian/Ho_Chi_Minh
Vncalendar::Converter.solar_to_lunar(Date.new(2014, 9, 23), UTC_OFFSET)
```

- Convert lunar date to solar date:

```ruby
UTC_OFFSET = 7 # Asian/Ho_Chi_Minh
LEAP_MONTH_OF_THE_YEAR = 0 # no leap month in this year.
Vncalendar::Converter.lunar_to_solar(Date.new(2014, 8, 30), LEAP_MONTH_OF_THE_YEAR, UTC_OFFSET)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can run one of these commands to run the test suite:

```ruby
rake test

# Or:
ruby -Ilib:test test/*
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kidlab/vncalendar.

## Credit

This code is ported from this repo https://github.com/vanng822/vncalendar - by Nguyen Van Nhu ([@vanng822](https://github.com/vanng822)), which is originally based on the [Algorithms for computing lunar calendar](http://www.informatik.uni-leipzig.de/~duc/amlich/calrules_en.html) ([Vietnamese version](http://www.informatik.uni-leipzig.de/~duc/amlich/calrules.html)) by Ho Ngoc Duc.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

