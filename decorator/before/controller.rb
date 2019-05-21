# app/controllers/api/v1/shops_controller.rb
module Api
  module V1
    class ShopsController < Api::V1::ApiController

      # ...

      def create
        @shop = Shop.new(params[:shop])
        head(:bad_request) unless @shop.save
      end

      # ...

    end
  end
end
