# Eithery Lab, 2017
# Shared examples for validators specs

module Gauge
  module Validators
    shared_examples_for "any database object validator" do
      subject { validator }

      it { should respond_to :check }
      it { should respond_to :errors }

      it { expect(validator.class).to respond_to :check_all }
      it { expect(validator.class).to respond_to :check_before }
      it { expect(validator.class).to respond_to :check }
      it { expect(validator.class).to respond_to :validate }

      it { expect(validator.errors).to_not be nil }
      it { expect(validator.errors).to be_empty }
    end
  end
end
