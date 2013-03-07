Ramaze::Helper::Fnordmetric
===========================

[![Build Status](https://secure.travis-ci.org/leucos/ramaze-fnordmetric.png?branch=master)](http://travis-ci.org/leucos/ramaze-fnordmetric)
[![Coverage
Status](https://coveralls.io/repos/leucos/ramaze-fnordmetric/badge.png?branch=master)](https://coveralls.io/r/leucos/ramaze-fnordmetric)


__A [Ramaze][1] helper that makes it easy to use [Fnordmetric][2] in your
  Ramaze web-applications__

----

Features
--------

Code metrics and event recording a-gogo.

See examples below.

Documentation
-------------

You can generate the doc with yard, or just brows it online on
[Rubydoc][3].
The source is hosted on [GitHub][4].

Usage
-----

### Using in your code ###

#### Installing ####

  `gem install ramaze-fnordmetric`

#### Loading the helper ####

Since this is a Ramaze helper, you can use it just like another helper :

    class Users < Controller
      helper :fnordmetric
      ...
    end

#### Redis configuration ####

Since Fnordmetric uses Redis, you can configure the server to use using traits
in your controller :

  `trait :fnord_redis_url => "redis://redis.example.com:6332"`

If not, Fnordmetric will use the default redis stuff (`redis://localhost:6379`).

You can also set how long the helper internal structures (timers, see below) 
will be kept in Redis using `trait :fnord_helper_key_ttl => 3600`

By default, they will be kept `Innate::Session.options.ttl` seconds.

#### Events and sessions ####

All Fnordmetric events are linked to the session (`innate.sid`) of the currently
handled request. This makes it easy to track which events occured in which
session.

If you're dealing with authenticated users, you might want to associate a name
to the user sessions so your Fnormetric app displays a user name instead of a
session id :

    # Associates a user name to the current innate.sid
    set_name("#{user.name} #{user.surname}")

You can also set a picture for the current session, using the gravatar helper for instance :

    # Fnordmetric will display a picture next to the user
    set_picture(gravatar(user.email.to_s)) if user.email

### Sending an event ###

To send an event to Fnordmetric, use the `event` method :

    event(:user_login, :is_admin => "yes")

### Recording page views

You can record a pageview Fnordmetric event using `pageview` :

    pageview '/some/page/path'

Since all events are sent along with the current session id, this leaves a nice 
per-session audit trail.

### Measuring execution time for code section ###

If you want to measure the time taken for a particular section of code, you can start a timer before your code, and stop it when you're done.

    # Measuring code execution times
    # We just start a stopwatch
    push_timer(:performance, :field => :whatever_you_want_here)

    # Oh well, I'm doing something here that needs to be measured
    sleep(1)

    # Let's stop the stopwatch
    # This automatically sends an event to Fnordmetric
    pop_timer

`push_timer` and `pop_timer` can be nested :

    def login
      @title = "Connect"

      redirect_referer if logged_in?
      return unless request.post?

      # Let's push a timer to get the overall login timings
      # We add some data to the event so we wan easily see what piece of code
      # is involved in our Fnordmetric app

      push_timer(:timing_data, :controller => :user, :method => :login)
      user_login(request.subset(:email, :password))

      # This is good, but we also want to see how much the following piece of
      # code takes too

      if logged_in?
        # Ok, now let's say we want to pre-fill some kind of cache for the user
        # and measure how long it takes

        # Let's fire another stopwatch
        push_timer(:timing_data, :code => :cache_retrieval)
        fill_cache(user)

        # Let's stop the last stopwatch, and send the event
        pop_timer

      else
        flash[:error] = "Can't log in, invalid data"
      end

      # Ok, we've done our job, let's stop the first stopwatch we started and 
      # send metric
      pop_timer

      redirect_referrer
    end

Easy peasy lemon squeezy.

### Measuring execution time for block ###

But the helper comes with block (like in &) timing methods too, so we can meke 
the above code event simpler, replacing the inner `push_timer` and `pop_timer` 
calls with the `times` method :

        # Ok, now let's say we want to pre-fill some kind of cache for the user
        # and measure how long it takes

        # Let's fire another stopwatch
        times(:timing_data, :code => :cache_retrieval) do
          fill_cache(user)
        end

Easier than before. The block passed to `times` will be measured.

### Measuring execution time for an action (controller method) ###

While the above block thing is nice, it could be great to do the same for a 
whole method. The helper can do this too with the `clock` method :

    def login
      @title = "Connect"

      # code code ...

      redirect_referrer
    end
    clock :login, :timing_data, :controller => :user,

This will automagically measure execution time for the :login method (first
arg), sending an event named `timing_data` with some arbitrary argument 
(controller in our case). 

Note that `clock` always sets the `:method` key value in the arguments sent in 
the event, so the tracked method is recorded in Fnordmetric.

Summing up, we can user all those methods like that :

    def login
      @title = "Connect"

      redirect_referer if logged_in?
      return unless request.post?

      # Log in this fellow
      user_login(request.subset(:email, :password))

      # This is good, but we also want to see how much the following piece of
      # code takes too

      if logged_in?
        # Hey, nice, user is logged in. Let'a associate name and picture as 
        # shown already

        set_name("#{user.name} #{user.surname}")
        set_picture(gravatar(user.email.to_s)) if user.email

        # Ok, now let's say we want to pre-fill some kind of cache for the user
        # and measure how long it takes

        # Let's fire another stopwatch
        push_timer(:timing_data, :code => :cache_retrieval)
        fill_cache(user)

        # Let's stop the last stopwatch, and send the event
        pop_timer

      else
        flash[:error] = "Can't log in, invalid data"
      end

      # Ok, we've done our job, let's stop the first stopwatch we started and 
      # send metric
      pop_timer

      redirect_referrer
    end
    # We want to measure the whole method
    clock :login, :timing_data, :controller => :user,


### Measuring all your actions time ###

Using Ramaze before/after controller facilities, you can easily measure 
everything, send events before each method onvocation, etc...

    class Controller < Ramaze::Controller
      layout :default
      helper :fnordmetric

      # Let's record all pageviews for all controllers     
      before_all do
        pageview request.env['REQUEST_PATH']
      end

### Starting the Fnordmetric app ###

Ok, now that we measure everything we want, how do we see the stuff ?
Well, you have to write a Fnordmetric app.

This is quite simple, and is explained in detail in the [Fnordmetric][2] docs.

Here is a small example the show pages views :


    #!/usr/bin/env ruby
    #
    require 'fnordmetric'

    FnordMetric.namespace :myapp do

    # Unique pageviews
    gauge :pageviews_daily_unique, :tick => 1.day.to_i, 
                                   :unique => true, 
                                   :title => "Unique Visits (Daily)"

    # _pageview is a special Fnordmetric event
    # and as such starts with `_`
    event :_pageview do
      # increment the daily_uniques gauge by 1 if session_key hasn't been seen
      # in this tick yet
      incr :pageviews_daily_unique
      # increment the pageviews_per_url_daily gauge by 1 where key = 'page2'
      incr_field :pageviews_per_url_daily, data[:url]
    end


    # Widgets
    widget 'Overview', {
      :title => "Visits per day",
      :type => :timeline,
      :plot_style => :areaspline,  
      :gauges => :pageviews_daily_unique,
      :include_current => true,
      :autoupdate => 10
    }

See the `examples/` directory for a worging example.

Caveats
-------

If sid changes (e.g. when a user logs in), timers won't pop properly. This
doesn't break, but will leave a nasty line in your logs. The next version will
take care of this.

Contributing
------------

fork / make a feature branch / change / specs / commit / send PR (devel branch)

Ack
---

Thanks to manveru & yorick for [Ramaze][1]. Man, those Rails zealots just don't 
realize their pathetic fate :)

License
-------

`ramaze-fnordmetric` is licensed under the MIT license :

Copyright (c) 2012, Michel Blanc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.



  [1]: https://github.com/ramaze/ramaze
  [2]: https://github.com/paulasmuth/fnordmetric
  [3]: http://rubydoc.info/github/leucos/ramaze-fnordmetric/master/frames
  [4]: https://github.com/leucos/ramaze-fnordmetric
