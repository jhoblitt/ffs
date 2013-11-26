require 'tsort'

module Facter
  module Core
    class Resolution

      attr_reader :name
      attr_reader :deps

      def initialize(fact, name, opts = {})
        @fact = fact
        @name = name

        @confines = []

        @opts = opts
        @deps = opts[:using] || []

        @block = nil
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

      def resolve(&block)
        @block = block
      end

      def value
        sorted_resolutions.inject(nil) do |accum, res|
          res.block.call(accum)
        end
      end

      include Comparable

      def <=>(other)
        self.weight <=> other.weight
      end

      def weight
        @confines.length
      end

      def block
        @block
      end
      protected :block

      def depgraph
        graph = Graph.new

        graph[@name] = @deps

        @deps.each do |depname|
          dep = @fact.resolution(depname)
          graph[depname] = dep.deps
        end

        puts graph.keys
        graph
      end

      def sorted_resolutions
        depgraph.tsort.map { |depname| @fact.resolution(depname) }
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
