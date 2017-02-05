require_relative "nazi_tests.rb"
require "geo_deluge"
require "museum_provenance"

module NaziHunter
  class NaziDetector
    
    include NaziHunter::NaziTests

    def initialize(opts = {})
      @strict          = opts.fetch(:strict, false)
      geo_deluge_cache = opts.fetch(:geo_deluge_cache, "./caches/fast_cache.json")
     
      @lookup = GeoDeluge::Lookup.new(cache_file: geo_deluge_cache)
    end


    def analyse_provenance(record)
      
      # initialize some useful variables
      provenance_text      = record["provenance"]
      places               = record["places"]
      artists              = record["actors"].find_all{|a| a["role"] == "creator"}
      artist_names         = artists.collect{|e| e["name"]}.flatten
      artist_nationalities = artists.collect{|e| e["nationality"]}.flatten
      per_test_options     = {places: places}
      scanned_periods      = []

      # Handle blank provenance
      if provenance_text.nil?
        return {
          status: NaziTests::PROBLEMATIC, 
          message: "No recorded provenance",
          periods: []
        }
      end

      # Handle unreadable or unbparsable provenance
      begin
        provenance_events = MuseumProvenance::Provenance.extract(provenance_text)
      rescue
        return {
          status: NaziTests::PROBLEMATIC, 
          message: "The provenance text was unreadable.",
          periods: []
        }
      end

      # If strict mode is disabled,
      # handle American works with no mention of Europe
      artist_is_american = (artist_nationalities.count == 1 && artist_nationalities.first == "American")
      if !@strict && artist_is_american && provenance_is_american(provenance_events, places) 
        return {
          status: NaziTests::SAFE, 
          message: "Artist is American, and none of the periods before #{END_OF_NAZI_ERA} mention Europe.",
          periods: []
        }
      end

      # Set the current period to the first transaction
      current_period  = provenance_events.earliest
      
      # Skip the first period if it is the artist
      # or the first period includes the word "artist" (unless @strict)
      if current_period && artist_names.include?(current_period.party.name)
        current_period = current_period.next_period
      elsif !@strict && current_period && current_period.to_s.downcase.include?("artist")
        current_period = current_period.next_period
      end
      if !current_period
        return {
          status: NaziTests::SAFE, 
          message: "The only recorded provenance is the artist.",
          periods: []
        }
      end

      while current_period
        # run each of the tests (unless one returns conclusively)
        conclusions = []
        NaziTests.public_instance_methods.each do |current_test|
          result = self.send(current_test, current_period, per_test_options)  
          conclusions << result
          if [NaziTests::PROBLEMATIC,NaziTests::SAFE,NaziTests::SKIP].include? result[0] 
            break
          end
        end

        # retrieve the result of the last test that was run
        final_conclusion = conclusions.last

        # structure the resulting data and save it
        period_results = {
          period_text: current_period.to_s,
          status: final_conclusion[0],
          message: final_conclusion[1] 
        }
        scanned_periods << period_results

        # move on to the next period if we haven't been able to determine
        # the final status of the provenance
        if [NaziTests::SKIP, NaziTests::INCONCLUSIVE].include? period_results[:status]
          current_period = current_period.next_period
        else
          current_period = nil
        end
      end

      begin
        return {
          status: scanned_periods.last[:status],
          message: scanned_periods.last[:message],
          periods: scanned_periods
        }
      rescue => e
        puts e
        puts scanned_periods.inspect
        puts record
        exit
      end
    end

    ############################################################################
    def provenance_is_american(provenance_events, places)
      work_is_american = false
     
      current_period  = provenance_events.earliest
      while current_period
        
        if (current_period.earliest_possible &&
           current_period.earliest_possible > END_OF_NAZI_ERA) ||
           current_period.next_period.nil?

           while current_period
             country = get_country(current_period,places)
             break if EUROPEAN_COUNTRIES.include?(country)
             current_period = current_period.previous_period
           end
           work_is_american = true
           break
        else
          current_period = current_period.next_period
        end
      end
      return work_is_american
    end

    ############################################################################
    def get_country(period, places)
      return nil if period.location.nil? || places.nil?
      loc = places.find{|p| p.keys.first == period.location.name}
      return nil if loc.nil?
      uri = loc.values.first
      id = @lookup.mapzen_id(uri)
      @lookup.get_country(id)
    end

    ############################################################################
    def output_text(record, show_provenance = false)
      return nil if record.nil?
      str = "#{record["accession_number"].to_s.ljust(10)} - #{record["title"]}\n"
      str += "-----------\n#{record["provenance"]}\n\n" if show_provenance
      str
    end
  end
end