AdhocScript = Struct.new( :description, :scope, :method, :params ) do
  SYMBOLS = ['-', "\\", '|', '/', '-', "\\", '|', '/']
  RECENT_WINDOW = 10

  def initialize( *args )
    super

    self.method ||= :find_each # the method to call on the scope
    self.params ||= []         # the arguments to @method

    unless self.scope.respond_to?(:count)
      raise ArgumentError.new( "#{self.scope.inspect} does not respond to `#count`" )
    end
    unless self.scope.respond_to?(self.method)
      raise ArgumentError.new( "#{self.scope.inspect} does not respond to `##{self.method}`" )
    end

    @terminal_columns = `/usr/bin/env tput cols`.to_i
  end

  def run( blk=nil )
    unless blk.respond_to?(:call) || block_given?
      raise ArgumentError.new( "A block or other callable is required to #run" )
    end

    reset
    print_progress

    scope.send( method, *params ) do |*args|
      begin
        block_given? ?
          yield( *args ) :
          blk.call( *args )
        @current += 1
        @complete = (@current / @total.to_f) * 100
        print_progress
      rescue => e
        print_error( e, args )
        return
      end
    end

    print_progress
    logger.puts "\n"
  end

  @logger = $stdout
  def self.logger=( logger ); @logger = logger; end
  def self.logger; @logger; end
  def logger; self.class.logger; end

  private

  def reset
    @start_time = Time.now.to_i # timestamp
    @symbols = SYMBOLS.dup      # nice rotating symbols :)
    @complete = 0.0             # completion percentage
    @current = 0                # index of current item
    @total = scope.count        # total items to process
    @recent_times = []          # last RECENT_WINDOW items process time
  end

  def time_remaining
    now = Time.now.to_i
    creep = (((now - @start_time) * 100) / @complete) - (now - @start_time)
    @recent_times = (@recent_times.unshift(creep)).slice( 0, RECENT_WINDOW )
    estimated_complete_time = now + (@recent_times.inject(:+) / @recent_times.size).to_i rescue nil
    distance_of_time_in_words( now, estimated_complete_time )
  end

  def next_symbol
    case completion_percentage
    when 100 then return '*'
    when 0 then return '-'
    else return @symbols.push( @symbols.shift ).first
    end
  end

  def distance_of_time_in_words( from, to )
    return nil if to.nil? || completion_percentage == 0 || @recent_times.empty?

    distance_in_seconds = (to - from).abs
    distance_in_minutes = (distance_in_seconds / 60.0).round

    case distance_in_minutes
    when 0
      case distance_in_seconds
      when 0..9 then 'less than 10 seconds'
      when 10..50 then "#{distance_in_seconds} seconds"
      else "less than 1 minute"
      end
    when 1 then "1 minute"
    when 2..44 then "#{distance_in_minutes} minutes"
    when 45..89 then "about 1 hour"
    when 90..1439 then "about #{(distance_in_minutes / 60.0).round} hours"
    when 1440..2519 then "1 day"
    when 2520..43199 then "#{(distance_in_minutes / 1440.0).round} days"
    else "an extremely long time"
    end
  end

  def completion_percentage
    @complete.ceil.to_i
  end

  def print_progress
    report = "#{next_symbol} #{description}: #{completion_percentage}%"
    unless (tr = time_remaining).nil?
      report += " (Remaining: #{tr})"
    end

    output = report.ljust(description.length + 50)
    output = output.slice( 0, @terminal_columns - 1 ) if @terminal_columns != 0

    logger.print output + "\r"
  end

  def print_error( e, args )
    # this is just for error handling/output purposes
    klass = scope.respond_to?(:klass) ? scope.klass : scope.class
    logger.print "\n\n"
    logger.puts "Script failed at #{completion_percentage}% on #{klass.name.to_s} with arguments: #{args.inspect}!"
    logger.print "\n\n"
    logger.puts e.message
    logger.puts e.backtrace.join("\n")
  end
end
