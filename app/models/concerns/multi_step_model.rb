module MultiStepModel
  extend ActiveSupport::Concern
  attr_writer :current_step

  included do |base|
    base.extend MultiStepModel::ClassMethods
  end

  module ClassMethods

    # Define which attributes should be visible at a given step.
    # @param step [Integer] where given attributes should be visible
    # @param args [Array]
    # @param nested [Hash]
    def step_attributes(step, *args, **nested)
      raise ArgumentError unless step.is_a? Integer
      @@step_attributes ||= {}

      if @@step_attributes[step].is_a? Hash
        @@step_attributes[step][:_attrs] = @@step_attributes[step][:_attr].merge(args)
        @@step_attributes[step].merge!(nested)
      else
        @@step_attributes[step] = nested
        @@step_attributes[step][:_attrs] = args
      end

    end

    # Set total steps of the class
    # @param i [Integer] total steps.
    def has_steps(i)
      @@total_steps = i
    end

    # @return [Integer] total steps of the class
    def total_steps
      @@total_steps
    rescue NameError
      raise StandardError, "Uninitialized class variable @@total_steps in #{self.name}. Use the class method has_steps(i) in the #{self.name} model or any superclass to fix this."
    end

    def method_missing(method_name, *args, &block)
      if /^step_(\d+)_attributes$/ =~ method_name
        if args.blank?
          @@step_attributes[$1.to_i]
        else
          step_attributes($1.to_i, args)
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, *)
      method_name =~ /^step_(\d+)_attributes$/ || super
    end

  end

  def current_step
    @current_step.to_i
  end

  def current_step_valid?
    valid?
  end

  def all_steps_valid?
    (0...self.class.total_steps).all? do |step|
      @current_step = step
      current_step_valid?
    end
  end

  def step_forward
    @current_step = current_step + 1
  end

  def step_back
    @current_step = current_step - 1
  end

  # Returns true if step is nil to ensure ALL validations are executed upon save/validate
  # (state of the object is considered to be "on every step" if step is nil).
  def step?(step)
    @current_step.nil? || current_step + 1 == step
  end

  def last_step?
    step?(self.class.total_steps)
  end

  def first_step?
    step?(1)
  end

  def method_missing(method_name, *args, &block)
    if /^step(\d+)\?$/ =~ method_name
      step?($1.to_i)
    else
      super
    end
  end

  def respond_to_missing?(method_name, *)
    method_name =~ /^step(\d+)\?$/ || super
  end

end