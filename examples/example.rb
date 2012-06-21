require 'ramaze'

# use : require 'ramaze-fnordmetric-helper' IRL
require __DIR__('../lib/ramaze/helper/fnordmetric')


class MainController < Ramaze::Controller
  include Ramaze::Traited
  map '/'
  helper :fnordmetric

#  trait :fnord_redis_url => "redis://localhost:6379"

  # We just use push_timer to mesure some time
  def index
    p request.inspect
    push_timer :stupid_sleep
    sleep 2
    pop_timer

    <<EOF
<h2>push_timer/pop_timer methods</h2>
This example uses push_timer/pop_timer methods

<pre>
  def index
    push_timer :stupid_sleep
    sleep 2
    pop_timer
  end
</pre>

If you run 'fn.rb' (bundle exec fn.rb run), you can check this <a href='http://localhost:4242'>link</a> to get the Fnordmetric dashboard.
<p />
Sorry for the wait... but congratulations won a vanilla Icecream <a href='/icecream'>Icecream</a> ! May be you prefer <a href='/icecream/strawberry'>strawberry</a>. ?
EOF
  end

  # Here we just interested in counting icecreams
  def icecream(flavor="vanilla")
    event(:icecream, :flavor => flavor)

    <<EOF2
<h2>event method</h2>
This example uses event to send an event to Fnordmetric.

<pre>
  def icecream(flavor="vanilla")
    event(:icecream, :flavor => flavor)
  end
</pre>

If you run 'fn.rb' (bundle exec fn.rb run), you can check the icecreams <a href='http://localhost:4242/example#dashboard/Overview'>page</a><p />
Sorry for the wait... You won a vanilla Icecream <a href='/icecream'>Icecream</a>. May be you prefer <a href='/icecream/strawberry'>strawberry</a> ? <p />
If you wish, we can <a href='/deliver'>deliver</a> the icecream to your door, but it might take some time, be patient.

EOF2
  end

  def deliver
    sleep(1 + rand)

    <<EOF3
<h2>clock class method</h2>
This example uses 'clock' to measure the time taken by a controller method.

<pre>
  def deliver
    sleep(rand * 10)
  end
  clock :deliver, :delivery_performance
</pre>

If you run 'fn.rb' (bundle exec fn.rb run), you can check the performance <a href='http://localhost:4242/example#dashboard/Performance'>tab</a><p />
Your icecream has been delivered. You can get <a href='/deliver'>another one</a> or go to the <a href='/'>index</a> page.<p />
EOF3
  end
  clock :deliver, :delivery_performance

end

Ramaze.start(:root => Ramaze.options.roots)
