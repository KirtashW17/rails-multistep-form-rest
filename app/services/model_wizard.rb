class ModelWizard
  attr_reader :object

  def initialize(object_or_class, params = {}, object_params = {})
    @object_or_class = object_or_class
    @params, @object_params = params, object_params
    @object_params.merge(@params["#{@param_key}"]) if @params["#{@param_key}"]
    @params.delete("#{@param_key}")
    @param_key = ActiveModel::Naming.param_key(object_or_class)
  end

  def start
    @object = load_object
    @object.current_step = @params[:step].to_i
    self
  end

  def continue
    @object = load_object
    @object.assign_attributes(@object_params) unless class?
    self
  end

  def save
    if @params[:back_button]
      @object.step_back
    elsif @object.current_step_valid?
      return process_save
    end
    false
  end

private

  def load_object
    current_step = @object_params['current_step']
    if class?
      @object_or_class.new(
        @object_params.merge('current_step' => current_step)
      )
    else
      @object_or_class
    end
  end

  def class?
    @object_or_class.is_a?(Class)
  end

  def process_save
    if @object.last_step?
      if @object.all_steps_valid?
        success = @object.save
        return success
      end
    else
      @object.step_forward
    end
    false
  end

end