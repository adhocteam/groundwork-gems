# frozen_string_literal: true

module Groundwork
  # Evaluates policy rules expressed as plain Ruby methods.
  #
  # Rules are defined on any Ruby object (a "ruleset"). Each public method is a
  # rule; its parameter names declare dependencies on other facts. The engine
  # resolves the dependency graph automatically via method introspection —
  # no explicit wiring required.
  #
  # Facts are evaluated lazily and memoized. A reasons tree is built alongside
  # each result so UIs can explain how a determination was reached.
  #
  # @example
  #   class PermitEligibilityRuleset
  #     def eligible?(prescreening_cleared, license_type_valid)
  #       prescreening_cleared && license_type_valid
  #     end
  #
  #     def license_type_valid(license_type)
  #       %w[limited_permit user_permit].include?(license_type)
  #     end
  #   end
  #
  #   engine = Groundwork::RulesEngine.new(PermitEligibilityRuleset.new)
  #   engine.set_facts(license_type: "limited_permit", prescreening_cleared: true)
  #   result = engine.evaluate(:eligible?)
  #   result.value    # => true
  #   result.reasons  # => [Fact(:prescreening_cleared, true), Fact(:license_type_valid, true)]
  #
  class RulesEngine
    # A computed or directly-set fact with its derivation history.
    class Fact
      attr_reader :name, :value, :reasons

      def initialize(name, value, reasons: [])
        @name    = name
        @value   = value
        @reasons = reasons
      end

      def unknown?
        @value.nil?
      end

      def to_s
        "#{name}: #{value.inspect}"
      end
    end

    # A directly-set input fact with no derivation history.
    class Input < Fact
      def initialize(name, value)
        super(name, value, reasons: [])
      end
    end

    def initialize(ruleset)
      @ruleset = ruleset
      @facts   = {}
    end

    # Seeds one or more input facts directly (no rule derivation).
    #
    # @param facts [Hash{Symbol, String => Object}]
    def set_facts(facts)
      facts.each do |name, value|
        @facts[name.to_sym] = Input.new(name.to_sym, value)
      end
    end

    # Evaluates (and memoizes) a named fact, recursively resolving dependencies.
    #
    # @param  fact_name [Symbol, String]
    # @return [Groundwork::RulesEngine::Fact]
    def evaluate(fact_name)
      fact_name = fact_name.to_sym
      return @facts[fact_name] if @facts.key?(fact_name)

      result = compute_fact(fact_name)
      @facts[fact_name] = result
      result
    end

    private

    def compute_fact(fact_name)
      unless @ruleset.respond_to?(fact_name)
        return Fact.new(fact_name, nil, reasons: [])
      end

      method      = @ruleset.method(fact_name)
      param_names = method.parameters.map { |_type, name| name }
      args        = param_names.map { |name| evaluate(name)&.value }
      value       = method.call(*args)

      Fact.new(
        fact_name,
        value,
        reasons: param_names.map { |name| @facts[name] }.compact
      )
    end
  end
end
