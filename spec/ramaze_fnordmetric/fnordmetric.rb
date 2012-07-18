require File.expand_path('../../helper', __FILE__)

# re-open logging stuff so we can trap when R:H:Fnordmetric spits out errors on
# console
module Innate
  class LogHub
    # Override error so we can be sure something broke
    def error(message)
      @@last_error = message
    end

    def last_error
      @@last_error
    end
  end
end

# Re-open helper class to mock redis-related methods
module Ramaze

  module Helper
    module Fnordmetric

      def self.redis
        @@redis
      end

      def self.fnord
        @@fnord
      end

      # Redis mocking class
      class RedisMock
        attr_accessor :list

        def initialize(whatever)
          @list = Array.new
        end

        def lpush(key, value)
          # We just don't care about key
          @list.push value
        end

        def lpop(key)
          @list.pop
        end

        def expire(key, ttl)
          # don't care
        end

        def llen(key)
          @list.count
        end

        def del(key)
          @list = []
        end

        def [](index)
          @list[index]
        end
      end

      # Fnordmetric mocking class
      class FnordMock
        attr_accessor :last

        def initialize(whatever)
          @last = nil
        end

        # This is called by Ramaze::Helper::Fnordmetric
        # and already formatted Fnordmetric-style
        def event(evt, args = {})
          @last = evt
        end
      end

      def _connect
        @@fnord = FnordMock.new(:redis_url => "mocked, muahahah")
        @@redis = RedisMock.new(:url => "mocked too, niark niark")
      end

    end
  end
end

# TODO: may be we should check if a redis server is available, and if not load
# the above code from a specific file

# guinea pig controller
class GuineaPig < Ramaze::Controller
  map '/'
  helper :fnordmetric

  def event_test(key, value)
    event(key, { :somefield => value })
  end

  def set_picture_test(url)
    set_picture(url)
  end

  def set_name_test(name)
    set_name(name)
  end

  def pageview_test(url)
    pageview(url)
  end

  def push_pop_test(name, value)
    push_timer(name, :somevalue => value)
    # noop
    pop_timer
  end

  def times_test(key, value)
    times(key, :somevalue => value) do
      true
    end
  end

  def clock_test
  end
  clock :clock_test, :i_like_to_clock_it_clock_it, :somevalue => "clo(a)cked !"

  def clear_timers_test
    clear_timers
  end

  def push_only_test(name, value)
    # This will leave an un-popped key in the redis stack
    push_timer(name, value)
  end

  def pop_only_test
    pop_timer
  end
end

# Convenience function to test multiple values
def check(args)
  args.each_pair do |k,v|
    Ramaze::Helper::Fnordmetric.fnord.last[k].should == v
  end
end

# Convenience debugging function
def debug(what)
  what = what.class == Array ? what : [ what ]
  pp Ramaze::Helper::Fnordmetric.fnord.last if what.include?(:fnord)
  pp Ramaze::Helper::Fnordmetric.redis.list if what.include?(:redis)
end


describe('Ramaze::Helper::Fnordmetric') do
  behaves_like :rack_test

  should 'send events' do
    get('/event_test/abcd/12').status.should == 200
    check({:_type => "abcd", :somefield => "12"})
  end

  should 'set picture' do
    get('/set_picture_test/this_is_my_pic_url').status.should == 200
    check({:_type => "_set_picture", :url => "this_is_my_pic_url"})
  end

  should 'set name' do
    get('/set_name_test/this_is_my_name').status.should == 200
    check({:_type => "_set_name", :name => "this_is_my_name"})
  end

  should 'handle pageview' do
    get('/pageview_test/my_fancy_url').status.should == 200
    check({:_type => "_pageview", :url => "my_fancy_url"})
  end

  should 'handle push_pop' do
    get('/push_pop_test/push_pop_url/push_pop_value').status.should == 200
    check({:_type => "push_pop_url", "somevalue" => "push_pop_value"})
    Ramaze::Helper::Fnordmetric.fnord.last[:time].should > 0
  end

  should 'handle clocking a block with times' do
    get('/times_test/times_url/times_value').status.should == 200
    check({:_type => "times_url", "somevalue" => "times_value"})
  end

  should 'handle clocking a block with times' do
    get('/clock_test').status.should == 200
    check({:_type => "i_like_to_clock_it_clock_it", "somevalue" => "clo(a)cked !"})
  end

  should 'clear timers' do
    get('/push_only_test/abcd/12').status.should == 200
    get('/clear_timers_test').status.should == 200
    Ramaze::Helper::Fnordmetric.redis.list.should.be.empty
  end

  should 'handle popping and empty stack gracefuly' do
    get('/pop_only_test').status.should == 200
    Ramaze::Log.last_error.should =~ /Unable to pop timer/
  end

end
