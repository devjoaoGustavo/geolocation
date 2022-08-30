module Api
  module V1
    class IpLocationsController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound do
        body = IpLocationSerializer.serialize_ip_location_not_found(params[:ip_address])

        render json: body, status: :not_found
      end

      rescue_from IPAddr::InvalidAddressError, IPAddr::AddressFamilyError do
        body = IpLocationSerializer.serialize_invalid_ip_address(params[:ip_address])

        render json: body, status: :unprocessable_entity
      end

      def search
        location = IpLocation.find IPAddr.new(params[:ip_address])

        render json: IpLocationSerializer.new(location).serialize, status: :ok
      end
    end
  end
end
