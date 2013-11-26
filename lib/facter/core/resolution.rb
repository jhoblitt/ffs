require 'tsort'

module Facter
  module Core
    class Resolution

      attr_reader :name

      def initialize(fact, name)
        @fact = fact
        @name = name

        @confines = []
      end

      def clear
        true
      end

      def confine(args = {})
        args.each do |arg|
          @confines << arg
        end
      end

      def suitable?
        true
      end

      def value
        raise NotImplementedError
      end

      include Comparable

      def <=>(other)
        self.weight <=> other.weight
      end

      def weight
        @confines.length
      end

      # Here at Puppet Labs, we fully endorse the use of graph theory to solve
      # all possible problems.
      #
      # @api WOOOOOO GRAPHS
      class Graph < Hash
        include TSort

        alias tsort_each_node each_key

        def tsort_each_child(node)
          fetch(node).each do |child|
            yield child
          end
        end
      end
    end
  end
end
