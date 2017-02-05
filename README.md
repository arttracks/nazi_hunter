# Nazi Hunter

This ruby library contains logic that automatically detects provenance records that contain transactions that indicate potential Nazi Era provenance.  To do so, we have leveraged the Art Tracks suite of tools, in particular the [`museum_provenance`](http://www.github.com/arttracks/museum_provenance) library, to construct a search pipeline that is capable of automatically detecting such provenance records with a reasonably high degree of accuracy.  

As part of museum accrediation requirement, museums are required to publish lists of objects that have potential Nazi Era provenance.  According to the [American Alliance of Museums](http://www.aam-us.org/resources/ethics-standards-and-best-practices/collections-stewardship/objects-during-the-nazi-era):

> ...[T]o aid in the identification and discovery of unlawfully appropriated objects that may be in the custody of museums, the Presidential Advisory Commission on Holocaust Assets in the United States (PCHA), Association of Art Museum Directors (AAMD), and the Alliance have agreed that museums should strive to: (1) identify all objects in their collections that were created before 1946 and acquired by the museum after 1932, that underwent a change of ownership between 1932 and 1946, and that were or might reasonably be thought to have been in continental Europe between those dates (hereafter, “covered objects”); (2) make currently available object and provenance (history of ownership) information on those objects accessible; and (3) give priority to continuing provenance research as resources allow. The Alliance, AAMD and PCHA also agreed that the initial focus of research should be European paintings and Judaica.

This is part of the Art Tracks project from the Carnegie Museum of Art in Pittsburgh, PA, and the research has been supported by a grant from the Samuel H. Kress Foundation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nazi_hunter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nazi_hunter

## Usage

Example: 

```
require 'nazi_hunter"
require 'JSON'

opts = {
      strict: false,                                 # - default value
      geo_deluge_cache: "./caches/fast_cache.json"   # - default value
    }

detector = NaziHunter::NaziDetector.new(opts)

provenance_record = <<~EOF
  {
    "internal_id": 1021550,
    "provenance": "Emmanuel and Mary Fellouzis, Wintersville, OH; gift to Carnegie Museum of Art, Pittsburgh, PA, February 1982.",
    "places": [
      {
        "Wintersville, OH": "https://whosonfirst.mapzen.com/data/101/713/127/101713127.geojson",
        "Pittsburgh, PA": "https://whosonfirst.mapzen.com/data/101/718/805/101718805.geojson"
      }
    ],
    "actors": [
      {
        "name": "A. W. Atkinson",
        "role": "creator",
        "nationality": "English"
      }
    ]
  }
  EOF

results = detector.analyse_provenance(JSON.parse(provenance_record))

# results == {
#   "status": "potential nazi era provenance",
#   "message": "There is no earliest date, and the first known date is after 1932-01-01",
#   "periods": [
#     {
#       "period_text": "Emmanuel and Mary Fellouzis, Wintersville, OH",
#       "status": "potential nazi era provenance",
#       "message": "There is no earliest date, and the first known date is after 1932-01-01"
#     }
#   ]
# }

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nazi_hunter.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

