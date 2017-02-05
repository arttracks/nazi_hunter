require "date"

module NaziHunter
  module NaziTests
    EUROPEAN_COUNTRIES = ["Albania", "Andorra", "Austria", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Czech Republic", "Denmark", "Estonia", "Faroe Islands", "Finland", "France", "Germany", "Gibraltar", "Greece", "Guernsey", "Hungary", "Isle of Man", "Jersey", "Italy", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Republic of Macedonia", "Romania", "Russia", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine", "United Kingdom", "Vatican City", "Republic of Ireland", "Iceland"] 
    PROBLEMATIC        = "potential nazi era provenance".to_sym
    SAFE               = "No potential nazi era provenance".to_sym
    SKIP               = "This period is not relevant for nazi era provenance".to_sym
    INCONCLUSIVE       = "This test cannot determine anything of interest".to_sym
    END_OF_NAZI_ERA    = Date.new(1946)
    BEGIN_OF_THE_NAZI_ERA = Date.new(1932)

    # Deal with works that have no dates, or a first date 
    # after the END_OF_NAZI_ERA:
    def no_info(current_period, opts={})
      if current_period.nil? || 
         current_period.previous_period.nil? &&
         current_period.earliest_possible && 
         current_period.earliest_possible > END_OF_NAZI_ERA
        [PROBLEMATIC, "This provenance's first recorded period begins after #{END_OF_NAZI_ERA}, so it must be flagged as potentially problematic."]
      else
        [INCONCLUSIVE, ""]
      end
    end

   
    def first_before_period(current_period, opts={})
      if current_period.latest_possible < BEGIN_OF_THE_NAZI_ERA
        [SKIP,"This period was before the nazi era"]
      else
        [INCONCLUSIVE,""]
      end
    end

    def final_transfer(current_period, opts={})
      if current_period.is_ongoing?
        return [SAFE, "All periods up to the present day appear to be safe"]
      else
        [INCONCLUSIVE, ""]
      end
    end

    def owned_throughout(current_period, opts={})
      if current_period.earliest_definite &&
         current_period.latest_definite &&
         current_period.earliest_definite < BEGIN_OF_THE_NAZI_ERA &&
         current_period.latest_definite > END_OF_NAZI_ERA
         [SAFE,"This work was owned throughout the nazi period by a single owner."]
       else
        [INCONCLUSIVE,""]
      end
    end

    def safely_after_nazi_era(current_period, opts={})
      if current_period.was_directly_transferred == true &&
        current_period.earliest_possible &&
        current_period.earliest_possible > END_OF_NAZI_ERA
        [SAFE, "All periods before the end of the nazi era are safe."]
      else
        [INCONCLUSIVE, ""]
      end
    end

    def no_dates(current_period, opts={})
      if current_period.next_period.nil? &&
         current_period.earliest_possible.nil?
         current_period.latest_definite.nil?
         [PROBLEMATIC, "This provenance has no recorded dates."]
      else
        [INCONCLUSIVE, ""]
      end
    end

    def european_transfer(current_period, opts={})
      return [INCONCLUSIVE, ""] if current_period.was_directly_transferred.nil?
      # return [INCONCLUSIVE, ""] if current_period.was_directly_transferred == false

      
      country1 = get_country(current_period,opts[:places])
      country2 = get_country(current_period.previous_period,opts[:places])

      if  ( EUROPEAN_COUNTRIES.include?(country1) ||
            EUROPEAN_COUNTRIES.include?(country2)   ) &&
          current_period.earliest_possible &&
          current_period.earliest_possible < END_OF_NAZI_ERA &&
          current_period.latest_possible > BEGIN_OF_THE_NAZI_ERA
          [PROBLEMATIC, "This provenance's has a european transfer during the nazi era"]
      else
        [INCONCLUSIVE,""]
      end
    end

    def gap_in_ownership(current_period, opts={})
      if current_period.was_directly_transferred == false &&
        current_period.earliest_definite &&
        current_period.earliest_possible < BEGIN_OF_THE_NAZI_ERA &&
        current_period.earliest_definite > END_OF_NAZI_ERA
        [PROBLEMATIC, "This provenance has an owner whose acquisition was during the nazi era."]
      else
        [INCONCLUSIVE, ""]
      end
    end

    def gap_during_nazi_era(current_period, opts={})
        if current_period.was_directly_transferred == false &&
        current_period.earliest_possible &&
        current_period.earliest_possible > BEGIN_OF_THE_NAZI_ERA &&
        (current_period.previous_period.latest_definite.nil? ||
          current_period.previous_period.latest_definite < END_OF_NAZI_ERA 
        )
        [PROBLEMATIC, "This provenance has an owner whose acquisition was during the nazi era."]
      else
        [INCONCLUSIVE, ""]
      end
    
    end

   
     def earliest_definite_too_late(current_period, opts={})
      if current_period.earliest_definite && 
         current_period.earliest_definite > BEGIN_OF_THE_NAZI_ERA && 
         !current_period.was_directly_transferred 
         [PROBLEMATIC, "There is a gap, and the first certain date is after #{BEGIN_OF_THE_NAZI_ERA}"]
      else
        [INCONCLUSIVE, ""]
      end
    end

    def first_known_too_late(current_period, opts={})
      if current_period.earliest_definite.nil? && 
         !current_period.was_directly_transferred &&
         current_period.latest_possible > BEGIN_OF_THE_NAZI_ERA
         [PROBLEMATIC, "There is no earliest date, and the first known date is after #{BEGIN_OF_THE_NAZI_ERA}"]
      else
        [INCONCLUSIVE, ""]
      end
    end

    def acq_encompases_nazi(current_period, opts={})
     if !current_period.was_directly_transferred &&
        current_period.earliest_possible && 
        current_period.earliest_definite &&
        current_period.earliest_possible < BEGIN_OF_THE_NAZI_ERA && 
        current_period.earliest_definite > BEGIN_OF_THE_NAZI_ERA
        [PROBLEMATIC, "an acquisition's uncertainty overlaps #{BEGIN_OF_THE_NAZI_ERA}"]
      else
        [INCONCLUSIVE, ""]
      end
    end
  end
end
