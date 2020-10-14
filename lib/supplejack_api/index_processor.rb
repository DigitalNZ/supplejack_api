# frozen_string_literal: true

class IndexProcessor
  def call
    loop do
      p 'Looking for records to index..'

      SupplejackApi::Record.any_of({ '$where' => 'this.processed_at < this.updated_at' }, processed_at: nil )
    end
  end
end
