# Eithery Lab, 2017
# Shared examples for database objects specs.

module Gauge
  module DB
    module SharedExamples
      shared_examples_for "any database object" do
        it { expect(dbo).to respond_to :name }

        describe '#name' do
          it "equals to the object name passed in the initializer" do
            expect(dbo.name).to eq dbo_name
          end
        end
      end
    end
  end
end
