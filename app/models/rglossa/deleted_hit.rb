module Rglossa
  class DeletedHit < ActiveRecord::Base
    belongs_to :search
  end
end