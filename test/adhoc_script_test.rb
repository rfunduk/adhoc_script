require_relative '../lib/adhoc_script'
require_relative './fake_model'
require 'minitest/autorun'
require 'minitest/unit'

AdhocScript.logger = File.open( "/dev/null", 'w' )

describe AdhocScript do

  it 'performs the base case' do
    adhoc = AdhocScript.new( 'Going through stuff', FakeModel )
    count = FakeModel::COUNT
    adhoc.run { count -= 1 }
    assert_equal 0, count
  end

  it 'works on other objects' do
    count = 100
    adhoc = AdhocScript.new( "Counting up to #{count}", (1..count), :each )
    adhoc.run { count -= 1 }
    assert_equal 0, count
  end

  it 'requires that the target responds to `#count`' do
    assert_raises( ArgumentError ) do
      AdhocScript.new( "Fail", 1 )
    end
  end

  it 'requires that the target responds to the method specified' do
    assert_raises( ArgumentError ) do
      AdhocScript.new( "Fail", [1,2,3], :nope )
    end
  end

  it 'requires a block (or other callable) to `#run`' do
    adhoc = AdhocScript.new( "Fail", [1,2,3], :each )
    assert_raises( ArgumentError ) { adhoc.run }
    assert_raises( ArgumentError ) { adhoc.run( 1 ) }
  end

  it '`#run` accepts anything which can be `#call`ed' do
    count = 100
    adhoc = AdhocScript.new( "Counting up to #{count}", (1..count), :each )
    callable = ->( i ) { count -= 1 }

    adhoc.run( callable )
    assert_equal 0, count

    count = 100
    adhoc.run( &callable )
    assert_equal 0, count

    count = 100
    adhoc.run { |i| callable.(i) }
    assert_equal 0, count
  end

end
