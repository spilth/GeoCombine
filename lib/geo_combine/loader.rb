# frozen_string_literal: true

require 'find'
require 'geo_combine/logger'

module GeoCombine
  # Loads Geoblacklight documents from a local directory
  class Loader
    attr_reader :directory, :schema_version

    def initialize(
      directory:,
      schema_version: ENV.fetch('SCHEMA_VERSION', 'Aardvark'),
      logger: GeoCombine::Logger.logger
    )
      @directory = directory
      @schema_version = schema_version
      @logger = logger
    end

    def docs_to_index
      return to_enum(:docs_to_index) unless block_given?

      @logger.info "Loading documents from #{directory}"
      Find.find(@directory) do |path|
        # skip non-json and layers.json files
        if File.basename(path) == 'layers.json' || !File.basename(path).end_with?('.json')
          @logger.debug "skipping #{path}; not a geoblacklight JSON document"
          next
        end

        doc = JSON.parse(File.read(path))
        [doc].flatten.each do |record|
          # skip indexing if this record has a different schema version than what we want
          record_schema = record['gbl_mdVersion_s'] || record['geoblacklight_version']
          record_id = record['layer_slug_s'] || record['dc_identifier_s']
          if record_schema != @schema_version
            @logger.debug "skipping #{record_id}; schema version #{record_schema} doesn't match #{@schema_version}"
            next
          end

          @logger.debug "found record #{record_id} at #{path}"
          yield record, path
        end
      end
    end
  end
end