# REST Multistep form wizard from scratch in Rails
This (Rails 5) project demonstrates how to break up a model-backed form into multiple steps without any gems nor using session.  This kind of thing can get pretty complex, but this implementation is fairly straightforward, flexible, and reusable. It can work with Rails 3-4 as well.

### Background
[This railscast](http://railscasts.com/episodes/217-multistep-forms) is a solid approach that I used as a starting point.  But there are a few problems with it that my project attempts to solve:

* Browser back/forward buttons shouldn't break it.
* Clicking "back" through the steps shouldn't validate the current step (maybe a personal preference?).
* Support for edit/update existing record.
* Keep the code out of the controller.
* Abstract the approach for any model.

### Installing
    git clone git://github.com/KirtashW17/rails-multistep-form-rest.git
    cd rails-multistep-form-rest
    bundle install
    rake db:migrate
    rake db:test:prepare
    rails s

Run `rspec` to run the tests, and/or visit http://localhost:3000/products.

If you have any issues, be sure you're using **Ruby >= 2.3**.

### Using in your own project
* Copy these files: **app/models/concerns/multi_step_model.rb**, **app/services/model_wizard.rb** and **app/helpers/model_wizard_form_builder.rb** (optional).
* In your model, `include MultiStepModel` and use class methods `has_steps(number_of_steps)` and `step_N_attributes(*attrs, **nested)` just like in the example (The last one only if you plan using the ModelWizardFormBuilder to create the hidden fields, otherwise you can just manually create the required hidden fields on each page) 
* Then just follow the conventions in this project that uses them. Check out the `ProductsController`, in particular, and the view form.

### Implementation details
* To validate an attribute, all that's needed is a conditional with the step to enforce validation:

```ruby
validates :name, presence: true, if: :step1?
validates :quantity, numericality: true, if: :step2?
```
* When using the `ModelWizardFormBuilder`, if you have defined which attributes are visible on each step on the respective model, you can create a set of hidden fields to keep inserted data between steps just like this (look at _layout.html.erb):
```
    <%= f.hidden_fields_for :name, :description, :quantity, :price, :available_at %>
    <%= f.hidden_fields_for :name, :id, parent: :categories %>
```
* If you create/update an object without the multistep form (i.e. in a test or the rails console), the step logic will be ignored and all fields will validate as expected.

### Features
* Multi or single step create/update.
* Not much code and abstracted to handle most models.
* Validate attributes per step with `stepX?` methods.
* RSpec/Capybara feature tests included.
* Browser back/forward should work as expected (Turbolinks not supported).

### Fork Modifications
* ModelWizard will no longer use session (cookie)
* Adds step_attributes class method when including MultiStepModel, this method allows to define the fields that should be show in any step.
* Adds custom FormBuilder that extends ActionView::Helpers::FormBuilder to easily create hidden fields that will displayed only when required (present in the object and not visible in current step)
* Using params instead of session fixes some nested models issues (failing test now works) and back/forward buttons w/ turbolinks.

### Limitations
While this works for most simple models, it's not flawless. Here are a few issues:
* Nested models may have issues, specially double nested ones (`has_many :foo, through: :bar`).
* Complicated fields such as uploads may be a problem.
