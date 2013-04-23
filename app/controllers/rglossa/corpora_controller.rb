module Rglossa
  class CorporaController < ApplicationController
    respond_to :json, :xml

    def index
      @corpora = Corpus.scoped
      set_query_params

      respond_with @corpora
    end


    def show
      @corpus = Corpus.scoped

      # params[:id] can be either the short_name of the corpus or its database
      # id as usual
      if params[:id].to_i > 0
        @corpus = @corpus.find(params[:id])
      else
        @corpus = @corpus.where(short_name: params[:id]).first
      end

      respond_to do |format|
        format.json do
          @metadata_categories = @corpus.metadata_categories.includes(:translations)

          render json: {
              corpus: @corpus.as_json(
                  only: [:id, :name, :short_name],
                  methods: :metadata_category_ids
              ),
              metadata_categories: @metadata_categories.as_json(
                  only: [:id, :name]
              )
          }
        end

        format.xml { render @corpus }  # don't include metadata in XML
      end
    end

    ########
    private
    ########

    def set_query_params
      query = params[:query]
      if query
        query.each_pair do |key, value|
          @corpora = @corpora.where(key.underscore.to_sym => value)
        end
      end
    end

  end
end