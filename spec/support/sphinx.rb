module SphinxHelpers
  def index_sphinx
    ThinkingSphinx::Test.index
    # Wait for Sphinx to finish loading in the new index files.
    sleep 0.25 until index_finished?
  end

  def index_finished?
    Dir[Rails.root.join(ThinkingSphinx::Test.config.indices_location, '*.{new,tmp}*')].empty?
  end
end

RSpec.configure do |config|
  config.include SphinxHelpers, type: :feature

  config.before(:suite) do
    # Ensure sphinx directories exist for the test environment
    ThinkingSphinx::Test.init
    # Configure and start Sphinx, and automatically
    # stop Sphinx at the end of the test suite.
    ThinkingSphinx::Test.start_with_autostop
  end

  config.before(:each) do |example|
    # Index data when running an acceptance spec.
    index_sphinx if example.metadata[:js]
  end
end
