module Rglossa
  module SearchEngines
    class CwbSearchesController < Rglossa::SearchesController

      # Used by the base controller to find the right kind of model to work with
      def model_class
        CwbSearch
      end

    end
  end
end