# frozen_string_literal: true
require 'ipaddr'

module Locations
  class Validator

    class << self
      ##
      # @param ip_address [String]
      # @param country_code [String]
      # @param country [String]
      # @param city [String]
      # @param latitude [String]
      # @param longitude [String]
      # @param mystery_value [String]
      # @return [Boolean]
      def valid?(*params)
        return false if params.count < 7
        return false unless valid_ip_address?(params[0])
        return false if params[1].nil? || params[1].empty?
        return false if params[2].nil? || params[2].empty?
        return false if params[3].nil? || params[3].empty?
        return false unless valid_coordinate?(params[4])
        return false unless valid_coordinate?(params[5])

        valid_integer?(params[6])
      end

      private

      def valid_ip_address?(ip_address)
        IPAddr.new(ip_address)
        true
      rescue IPAddr::Error
        false
      end

      def valid_coordinate?(value) = value.to_f.to_s == value

      def valid_integer?(value) = value.to_i.to_s == value
    end
  end
end
