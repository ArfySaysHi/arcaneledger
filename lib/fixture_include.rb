# frozen_string_literal: true

# Handles including yaml files within yml fixtures
class FixtureInclude
  FIXTURE_PATH = 'test/fixtures'

  def self.merge(dir, file_names)
    records = {}

    file_names.each do |name|
      path = "#{FIXTURE_PATH}/#{dir}/#{name}.yaml"
      records.merge! YAML.load_file(path)
    end

    records.to_yaml
  end
end
