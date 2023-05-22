# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Maps ActiveRecord record fields to values for display (e.g. in tables).
      class DisplayValueMapping
        include RecordMapping

        def numeric_value
          value_from_record
        end

        def json_value
          ActiveElement.json_pretty_print(value_from_record)
        end

        def string_value
          value_from_record
        end

        def datetime_value
          value_from_record.strftime('%Y-%m-%d %H:%M:%S')
        end

        def time_value
          value_from_record.strftime('%H:%M:%S')
        end

        def date_value
          value_from_record.strftime('%Y-%m-%d')
        end

        def boolean_value
          component.controller.render_to_string(
            partial: 'active_element/components/fields/boolean',
            locals: { value: value_from_record }
          )
        end

        def geometry_value
          require 'rgeo/geo_json'
          Util.json_pretty_print(RGeo::GeoJSON.encode(value_from_record))
        end
      end
    end
  end
end
