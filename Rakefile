require File.expand_path('../lib/ramaze/helper/fnordmetric', __FILE__)

module Ramaze
  module Helper
    module Fnordmetric
      Gemspec = Gem::Specification::load(
        File.expand_path('../ramaze-fnordmetric.gemspec', __FILE__)
      )
    end
  end
end

task_dir = File.expand_path('../task', __FILE__)

Dir.glob("#{task_dir}/*.rake").each do |f|
  import(f)
end
