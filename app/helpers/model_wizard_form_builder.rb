class ModelWizardFormBuilder < ActionView::Helpers::FormBuilder

  # Create hidden fields for the given args
  # @param args [Array] hidden fields to create
  # @param opts [Hash] options
  # @option opts [Symbol, String] parent parent of the given args for nested relation
  # @return [ActiveSupport::SafeBuffer] HTML Safe hidden fields.
  def hidden_fields_for(*args, **opts)
    hidden_fields = ''
    if opts[:parent].present?
      nested_child_name = nil
      hidden_fields = self.fields_for opts[:parent] do |f|
        nested_child_name = f.object_name.gsub(/\[\d+\]/, '')
        safe_hidden_field_tags(f, args, self)
      end
      self.reset_nested_child_index(nested_child_name)
    else
      hidden_fields = safe_hidden_field_tags(self, args)
    end
    hidden_fields
  end

  private

  def reset_nested_child_index(name)
    @nested_child_index[name] = nil
  end

  def safe_hidden_field_tags(f, args, parent = nil)
    r = ''
    args.each do |arg|
      r << f.hidden_field(arg).to_s unless visible_or_empty?(f, arg, parent)
    end
    r.html_safe
  end

  def visible_or_empty?(f, arg, parent)
    if parent.nil?
      if f.object.send(arg).blank?
        true
      else
        current_step = f.object.current_step + 1
        visible_attributes = f.object.class.send("step_#{current_step}_attributes")
        visible_attributes[:_attrs]&.include?(arg) if visible_attributes.present?
      end
    else
      current_step = parent.object.current_step + 1
      visible_attributes = parent.object.class.send("step_#{current_step}_attributes")
      key = parent.object.class.reflect_on_all_associations.select{|ass| ass.class_name == f.object.class.name}.first&.name
      visible_attributes.blank? or parent.object.send(key).empty? or
        parent.object.send(key).none?(&:changed?) or visible_attributes[key]&.include? arg
    end
  end

end