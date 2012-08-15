require 'spec_helper'

describe DidacticUnit do
  let(:didactic_unit) { DidacticUnit.new :content => content }
  describe '#lecture_themes' do
    subject { didactic_unit.lecture_themes }
    describe 'should split items' do
      describe 'by paragraph' do
        let(:content) { "item1\n \nitem2" }
        it { should == %w[item1 item2] }
      end

      describe 'by . inside paragraphs' do
        let(:content) { "item1. item2\n item3." }
        it { should == %w[item1 item2 item3] }
      end
    end
  end
end
