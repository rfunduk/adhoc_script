class FakeModel
  COUNT = 10
  def self.find_each( &block )
    COUNT.times do
      yield 1
    end
  end
  def self.count
    COUNT
  end
end
