require File.expand_path('../../helper', __FILE__)


class SpecEnvironment < Ramaze::Controller
  map '/'
  helper :fnordmetric

  def index
  end

end

describe('Ramaze::Helper::Fnordmetric') do
  behaves_like :rack_test
  end
end
