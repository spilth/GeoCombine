# frozen_string_literal: true

require 'git'
require 'geo_combine/loader'
require 'spec_helper'

RSpec.describe GeoCombine::Loader do
  subject(:loader) { described_class.new(directory: 'spec/fixtures/indexing', schema_version: '1.0') }

  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil, debug: nil) }

  describe '#docs_to_index' do
    it 'yields each JSON record with its path, skipping layers.JSON' do
      expect { |b| loader.docs_to_index(&b) }.to yield_successive_args(
        [JSON.parse(File.read('spec/fixtures/indexing/basic_geoblacklight.json')), 'spec/fixtures/indexing/basic_geoblacklight.json'],
        [JSON.parse(File.read('spec/fixtures/indexing/geoblacklight.json')), 'spec/fixtures/indexing/geoblacklight.json']
      )
    end

    it 'skips records with a different schema version' do
      loader = described_class.new(directory: 'spec/fixtures/indexing/', schema_version: 'Aardvark', logger:)
      expect { |b| loader.docs_to_index(&b) }.to yield_successive_args(
        [JSON.parse(File.read('spec/fixtures/indexing/aardvark.json')), 'spec/fixtures/indexing/aardvark.json']
      )
    end
  end
end
