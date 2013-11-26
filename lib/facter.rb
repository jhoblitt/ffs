require 'facter/core/fact'

module Facter
  def self.fact(name)
    @facts ||= {}

    @facts[name] ||= Facter::Core::Fact.new(name)
  end

  def self.debug(*args)
    puts "FACTER DEBUG: #{args.inspect}"
  end
end
