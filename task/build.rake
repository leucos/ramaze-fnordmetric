# Task group used for building various elements such as the Gem and the
# documentation.
namespace :build do
  desc 'Builds the documentation using YARD'
  task :doc do
    gem_path = File.expand_path('../../', __FILE__)
    command  = "yard doc #{gem_path}/lib -m markdown -M rdiscount -o #{gem_path}/doc "
    command += "-r #{gem_path}/README.md --private --protected"

    sh(command)
  end

  desc 'Builds a new Gem'
  task :gem do
    gem_path     = File.expand_path('../../', __FILE__)
    gemspec_path = File.join(
      gem_path,
      "#{Ramaze::Helper::Fnordmetric::Gemspec.name}-" \
        "#{Ramaze::Helper::Fnordmetric::Gemspec.version.version}.gem"
    )

    pkg_path = File.join(
      gem_path,
      'pkg',
      "#{Ramaze::Helper::Fnordmetric::Gemspec.name}-" \
        "#{Ramaze::Helper::Fnordmetric::Gemspec.version.version}.gem"
    )

    # Build and install the gem
    sh('gem', 'build'     , File.join(gem_path, 'ramaze-fnordmetric.gemspec'))
    sh('mv' , gemspec_path, pkg_path)
  end
end # namespace :build

