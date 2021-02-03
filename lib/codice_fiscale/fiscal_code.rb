module CodiceFiscale
  class FiscalCode
    include Helpers
    include Configurable

    attr_accessor :italian_citizen
    alias citizen italian_citizen

    CITIZEN_ATTRIBUTES = %i[name surname year birthdate city_name province_code country_name gender birthplace]

    def initialize(arg)
      if arg.instance_of? ItalianCitizen
        @italian_citizen = arg

        calculate
      else
        @code = arg
      end
    end

    def method_missing(m, *args, &block)
      if m.to_s.start_with?('extract_') &&
         ((parts = m.to_s.split('_')) &&
         Codes::PARTS.key?(parts.last.to_sym))
        extract(parts.last)
      elsif (parts = m.to_s.split('=')) && CITIZEN_ATTRIBUTES.include?(parts.first.to_sym)
        citizen.send("#{parts.last}=", args.first)

        calculate
      else
        super
      end
    end

    def to_s
      @code.to_s
    end

    def calculate
      (@code = surname_part + name_part + birthdate_part + birthplace_part) + control_character(@code)
    end

    def control_character(partial_fiscal_code)
      numeric_value = 0
      partial_fiscal_code.split('').each_with_index do |chr, index|
        numeric_value += (index + 1).even? ? Codes.even_character(chr) : Codes.odd_character(chr)
      end
      Codes.control_character numeric_value % 26
    end

    def consonants_of_name
      consonants citizen.name.upcase
    end

    private

    def surname_part
      first_three_consonants_than_vowels citizen.surname
    end

    def name_part
      return "#{consonants_of_name[0]}#{consonants_of_name[2..3]}" if consonants_of_name.size >= 4

      first_three_consonants_than_vowels citizen.name
    end

    def birthdate_part
      code = citizen.birthdate.year.to_s[2..3]
      code << Codes.month_letter(citizen.birthdate.month)
      code << day_part
    end

    def day_part
      number = citizen.female? ? citizen.birthdate.day + 40 : citizen.birthdate.day
      number.to_s.rjust(2, '0')
    end

    def birthplace_part
      code = citizen.born_in_italy? && Codes.city(citizen.city_name,
                                                  citizen.province_code) || Codes.country(citizen.country_name)
      unless code
        raise "Cannot find a valid code for #{[citizen.country_name, citizen.city_name,
                                               citizen.province_code].compact.join ', '}"
      end

      code
    end

    def extract(part)
      calculate if @italian_citizen

      part = part.to_sym

      case part
      when :surname, :name, :year, :month, :day, :gender, :birthplace
        @code[Codes::PARTS[part]]
      when :birthdate
        year = @code.slice(Codes::PARTS[:year]).to_i
        year = if year < 21
                 2000 + year
               else
                 1900 + year
               end
        month = Codes::MONTH_CODES.find_index(@code.slice(Codes::PARTS[:month])) + 1
        day = @code.slice(Codes::PARTS[:day]).to_i
        day -= 40 if day >= 41

        Date.new(year, month, day)
      end
    end
  end
end
