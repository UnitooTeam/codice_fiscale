require 'spec_helper'

describe CodiceFiscale::FiscalCode do
  let(:citizen_marco_galli) do
    CodiceFiscale::ItalianCitizen.new(
      name: 'Marco',
      surname: 'Galli',
      gender: :male,
      birthdate: Date.new(1983, 5, 3),
      city_name: 'Oggiono',
      province_code: 'LC'
    )
  end

  let(:fiscal_code) { described_class.new citizen_marco_galli }

  describe '#surname_part' do
    it 'takes the first 3 consonants' do
      expect(fiscal_code.extract_surname).to eq 'GLL'
    end

    it 'is 3 chrs long' do
      expect(fiscal_code.extract_surname.size).to eq 3
    end

    context 'when surname has only 1 consonant' do
      before { fiscal_code.surname = 'oof' }

      it 'puts the vowels after the consonants' do
        expect(fiscal_code.extract_surname).to eq 'FOO'
      end
    end

    context 'when surname is less than 3 chrs long' do
      before { fiscal_code.surname = 'm' }

      it 'pads with the "X" character' do
        expect(fiscal_code.extract_surname).to eq 'MXX'
      end
    end
  end

  describe '#name_part' do
    it 'is 3 chrs long' do
      expect(fiscal_code.extract_name.size).to eq 3
    end

    context 'when name has 4 or more consonants' do
      before { fiscal_code.name = 'danielino' }

      it 'takes the 1st the 3rd and the 4th' do
        expect(fiscal_code.extract_name).to eq 'DLN'
      end
    end

    context 'when name has 3 or less consonants' do
      before { fiscal_code.name = 'daniele' }

      it 'takes the first 3 consonants' do
        expect(fiscal_code.extract_name).to eq 'DNL'
      end
    end

    context 'when name has 2 consonants' do
      before { fiscal_code.name = 'bar' }

      it 'puts the vowels after the consonants' do
        expect(fiscal_code.extract_name).to eq 'BRA'
      end
    end

    context 'name is less than 3 chrs long' do
      before { fiscal_code.name = 'd' }

      it 'pad with the "X" character' do
        expect(fiscal_code.extract_name).to eq 'DXX'
      end
    end
  end

  describe '#birthdate_part' do
    it 'start with the last 2 digit of the year' do
      expect(fiscal_code.extract_year).to start_with '83'
    end

    describe 'the 3rd character' do
      before do
        allow(CodiceFiscale::Codes).to receive(:month_letter).and_return('X')
      end

      it 'is the month code' do
        expect(fiscal_code.extract_month).to eq 'X'
      end
    end

    describe 'the last 2 character' do
      context 'gender is male' do
        before { fiscal_code.gender = :male }

        it('is the birth day') { expect(fiscal_code.extract_day).to eq '03' }
      end

      context 'gender is female' do
        before { fiscal_code.gender = :female }

        it('is the birth day + 40') { expect(fiscal_code.extract_day).to eq '43' }
      end
    end
  end

  describe '#birthplace_part' do
    context 'when the country is Italy' do
      before { fiscal_code.country_name = 'Italia' }

      context 'when codes are fetched using a proc' do
        before { fiscal_code.config.city_code { 'Z999' } }

        it 'returns the result of the city-block execution' do
          expect(fiscal_code.extract_birthplace).to eq 'Z999'
        end
      end

      context 'when codes are fetched using csv' do
        before do
          allow(CodiceFiscale::Codes).to receive(:city).and_return('Z888')
        end

        it 'returns the city code' do
          expect(fiscal_code.extract_birthplace).to eq 'Z888'
        end
      end
    end

    context 'when the country is not Italy' do
      before { fiscal_code.country_name = 'Francia' }

      context 'when codes are fetched using a proc' do
        before { fiscal_code.config.country_code { 'H111' } }

        it 'returns the result of the country-block execution' do
          expect(fiscal_code.extract_birthplace).to eq 'H111'
        end
      end

      context 'when codes are fetched using csv' do
        before do
          allow(CodiceFiscale::Codes).to receive(:country).and_return('H222')
        end

        it 'returns the country code' do
          expect(fiscal_code.extract_birthplace).to eq 'H222'
        end
      end
    end
  end

  describe '#control_character' do
    it 'returns the expected letter' do
      expect(fiscal_code.control_character('RSSMRA87A01A005')).to eq 'V'
    end
  end
end
