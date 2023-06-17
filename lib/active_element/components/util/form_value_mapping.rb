# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Maps ActiveRecord record fields to values for editing in forms.
      class FormValueMapping
        include RecordMapping

        def numeric_value
          value_from_record
        end

        def json_value
          value_from_record
        end

        def string_value
          value_from_record
        end

        def datetime_value
          with_timezone_offset(value_from_record).strftime('%Y-%m-%d %H:%M:%S')
        end

        def time_value
          with_timezone_offset(value_from_record).strftime('%H:%M:%S')
        end

        def date_value
          with_timezone_offset(value_from_record).strftime('%Y-%m-%d')
        end

        def boolean_value
          value_from_record
        end

        def geometry_value
          require 'rgeo/geo_json'
          RGeo::GeoJSON.encode(value_from_record).to_json
        end
      end
    end
  end
end
