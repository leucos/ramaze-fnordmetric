require 'bacon'
require File.expand_path('../bacon/color_output', __FILE__)
require 'ramaze/spec/bacon'

Bacon.extend(Bacon::ColorOutput)
Bacon.summary_on_exit
