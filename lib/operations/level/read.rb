module Operations
  class Level::Read < Base
    def run
      model if allowed?
    end
  end
end
