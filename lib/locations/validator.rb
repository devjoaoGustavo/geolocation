# frozen_string_literal: true
require 'ipaddr'

module Locations
  class Validator

    class << self
      ##
      # @param location_row [CSV::Row]
      # @return [Boolean]
      def valid?(location_row)
        all_fields_valid?(location_row)
      end

      private

      def all_fields_valid?(location_row)
        return false unless valid_ip_address?(location_row['ip_address'])
        return false if location_row['country_code'].nil?
        return false if location_row['country'].nil?
        return false if location_row['city'].nil?
        return false unless valid_coordinate?(location_row['latitude'])
        return false unless valid_coordinate?(location_row['longitude'])
        return false unless valid_integer?(location_row['mystery_value'])

        true
      end

      def valid_ip_address?(ip_address)
        IPAddr.new(ip_address)
        true
      rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
        false
      end

      def valid_coordinate?(value)
        value.to_f.to_s == value
      end

      def valid_integer?(value)
        value.to_i.to_s == value
      end
    end
  end
end
