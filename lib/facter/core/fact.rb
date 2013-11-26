require 'facter/core/resolution'

module Facter
  module Core
    class Fact

      def initialize(name)
        @name = name

        @resolutions = []

        @value = nil
      end

      attr_reader :resolutions

      def resolution(name, &block)
        res = @resolutions.find { |res| res.name == name }

        if res.nil?
          res = Facter::Core::Resolution.new(self, name)
          @resolutions << res
        end

        res.instance_eval(&block) if block
        res
      end

      def clear
        @value = nil
        @resolutions.each(&:clear)
      end

      def value
        return @value unless @value.nil?

        ordered = order_resolutions

        if ordered.empty?
          Facter.debug("Fact #{@name} cannot be resolved: no suitable resolutions")
        end

        ordered.each do |res|
          resolved = res.value

          if not resolved.nil?
            @value = resolved
            break
          end
        end

        @value
      end

      private

      def order_resolutions
        @resolutions.select { |res| res.suitable? }.sort
      end
    end
  end
end
